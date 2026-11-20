#!/usr/bin/env python3
"""Run local HTTPS, DAV, and Authelia OIDC regressions; see README.md."""
import argparse
import base64
from contextlib import ExitStack
import hashlib
import hmac
import http.cookiejar
import json
import os
from pathlib import Path
import re
import secrets
import socket
import ssl
import subprocess
import tempfile
import time
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlencode, urlsplit
from urllib.request import (HTTPCookieProcessor, HTTPRedirectHandler, HTTPSHandler,
                            ProxyHandler, Request, build_opener)
import xml.etree.ElementTree as ET

HOST = 'localhost.localdomain'
USER = 'alice'


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def allocate_ports():
    with ExitStack() as stack:
        listeners = [stack.enter_context(socket.socket()) for _ in range(4)]
        for listener in listeners:
            listener.bind(('127.0.0.1', 0))
        return [listener.getsockname()[1] for listener in listeners]


def run(*command, **kwargs):
    return subprocess.check_output(command, text=True, **kwargs).strip()


def setup_auth(root, origin, port, password, client_secret):
    key = root / 'oidc.key'
    run('openssl', 'genpkey', '-algorithm', 'RSA', '-out', key, stderr=subprocess.DEVNULL)
    users = root / 'users.json'
    digest = run('authelia', 'crypto', 'hash', 'generate', 'argon2', '--password', password).split('Digest: ')[1]
    users.write_text(json.dumps({'users': {USER: {
        'displayname': 'Alice', 'password': digest, 'email': 'alice@example.test', 'groups': ['calendar'],
    }}}))
    digest = run('authelia', 'crypto', 'hash', 'generate', 'pbkdf2', '--password', client_secret).split('Digest: ')[1]
    path = root / 'authelia.json'
    path.write_text(json.dumps({
        'server': {'address': f'tcp://127.0.0.1:{port}/'},
        'ntp': {'disable_startup_check': True},
        'authentication_backend': {'file': {'path': str(users)}, 'password_reset': {'disable': True}},
        'access_control': {'default_policy': 'two_factor'},
        'session': {'secret': secrets.token_hex(32), 'cookies': [{'domain': HOST, 'authelia_url': origin}]},
        'storage': {'encryption_key': secrets.token_hex(32), 'local': {'path': str(root / 'auth.sqlite')}},
        'notifier': {'filesystem': {'filename': str(root / 'notifications.txt')}},
        'identity_providers': {'oidc': {
            'hmac_secret': secrets.token_hex(32), 'jwks': [{'algorithm': 'RS256', 'key': key.read_text()}],
            'clients': [{
                'client_id': 'rustical-test', 'client_secret': digest, 'public': False,
                'authorization_policy': 'two_factor', 'consent_mode': 'implicit',
                'require_pkce': True, 'pkce_challenge_method': 'S256',
                'redirect_uris': [origin + '/cal/frontend/login/oidc/callback'],
                'scopes': ['openid', 'profile', 'groups'], 'grant_types': ['authorization_code'],
                'response_types': ['code'], 'token_endpoint_auth_method': 'client_secret_basic',
            }],
        }},
    }))
    subprocess.run(['authelia', '--config', path, 'config', 'validate'], check=True)
    run('authelia', '--config', path, 'storage', 'migrate', 'up')
    totp_secret = secrets.token_bytes(32)
    run('authelia', '--config', path, 'storage', 'user', 'totp', 'generate', USER,
        '--secret', base64.b32encode(totp_secret).decode().rstrip('='))
    return path, totp_secret


def rustical_config(root, port, base='', oidc=''):
    path = root / f'rustical-{port}.toml'
    # Omit the new option at root so the regression checks existing configs.
    base_setting = f'base_path = {json.dumps(base)}' if base else ''
    path.write_text(f'''[http]
bind = "127.0.0.1:{port}"
{base_setting}
[data_store.sqlite]
db_url = {json.dumps(str(root / f'db-{port}.sqlite'))}
{oidc}
''')
    return path


def totp(secret):
    digest = hmac.digest(secret, (int(time.time()) // 30).to_bytes(8, 'big'), hashlib.sha1)
    offset = digest[-1] & 15
    return f'{(int.from_bytes(digest[offset:offset + 4], "big") & 0x7fffffff) % 1000000:06d}'


def check(rustical, root):
    proxy_port, auth_port, root_port, cal_port = allocate_ports()
    origin = f'https://{HOST}:{proxy_port}'
    password, client_secret = secrets.token_urlsafe(24), secrets.token_urlsafe(32)
    ca, ca_key = root / 'ca.pem', root / 'ca.key'
    cert, key, csr = root / 'cert.pem', root / 'tls.key', root / 'tls.csr'
    run('openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-nodes', '-days', '1',
        '-subj', '/CN=Rustical test CA', '-addext', 'keyUsage=critical,keyCertSign,cRLSign',
        '-keyout', ca_key, '-out', ca, stderr=subprocess.DEVNULL)
    run('openssl', 'req', '-new', '-newkey', 'rsa:2048', '-nodes', '-subj', f'/CN={HOST}',
        '-addext', f'subjectAltName=DNS:{HOST}', '-keyout', key, '-out', csr, stderr=subprocess.DEVNULL)
    run('openssl', 'x509', '-req', '-in', csr, '-CA', ca, '-CAkey', ca_key, '-CAcreateserial',
        '-copy_extensions', 'copy', '-days', '1', '-out', cert, stderr=subprocess.DEVNULL)
    auth_config, totp_secret = setup_auth(root, origin, auth_port, password, client_secret)
    default_config = rustical_config(root, root_port)
    cal_config = rustical_config(root, cal_port, '/cal', f'''[frontend]
allow_password_login = false
[oidc]
name = "Authelia"
issuer = "{origin}"
client_id = "rustical-test"
client_secret = "{client_secret}"
scopes = ["openid", "profile", "groups"]
claim_userid = "preferred_username"
require_group = "calendar"
allow_sign_up = true
''')
    run(rustical, '-c', default_config, 'principals', 'create', USER, '--for-testing-password-from-arg', password)
    caddy_config = root / 'Caddyfile'
    caddy_config.write_text(f'''{{
    admin off
    auto_https disable_redirects
}}
{origin} {{
    bind 127.0.0.1
    tls {cert} {key}
    @cal path /cal /cal/*
    handle @cal {{
        reverse_proxy 127.0.0.1:{cal_port}
    }}
    @discovery path /.well-known/caldav /.well-known/carddav
    handle @discovery {{
        rewrite * /cal{{uri}}
        reverse_proxy 127.0.0.1:{cal_port}
    }}
    handle {{
        reverse_proxy 127.0.0.1:{auth_port}
    }}
}}
''')
    env = dict(os.environ, SSL_CERT_FILE=str(ca), XDG_CONFIG_HOME=str(root / 'config'),
               XDG_DATA_HOME=str(root / 'data'), NO_PROXY=HOST, no_proxy=HOST)
    context = ssl.create_default_context(cafile=str(ca))
    browser = build_opener(ProxyHandler({}), HTTPSHandler(context=context), NoRedirect(),
                           HTTPCookieProcessor(http.cookiejar.CookieJar()))
    clean = build_opener(ProxyHandler({}), HTTPSHandler(context=context), NoRedirect())

    def request(path, code, method='GET', data=None, headers=None, opener=browser):
        url = origin + path if path.startswith('/') else path
        # These tests must never follow a bad redirect to a non-fixture host.
        assert urlsplit(url).netloc in (urlsplit(origin).netloc, f'127.0.0.1:{root_port}'), urlsplit(url).netloc
        req = Request(url, method=method, data=data, headers=headers or {})
        try:
            response = opener.open(req, timeout=10)
        except HTTPError as error:
            response = error
        with response:
            body = response.read()
            assert response.code == code, (method, urlsplit(url).path, response.code, code, body[:300])
            return response.headers, body

    def form(path, code, **data):
        return request(path, code, 'POST', urlencode(data).encode(),
                       {'Content-Type': 'application/x-www-form-urlencoded'})

    def auth(path, **data):
        return request(path, 200, 'POST', json.dumps(data).encode(), {'Content-Type': 'application/json'})

    def basic(secret):
        return {'Authorization': 'Basic ' + base64.b64encode(f'{USER}:{secret}'.encode()).decode()}

    processes = []
    try:
        for name, args in (
            ('root', [rustical, '-c', default_config, 'serve']),
            ('cal', [rustical, '-c', cal_config, 'serve']),
            ('auth', ['authelia', '--config', auth_config]),
            ('caddy', ['caddy', 'run', '--config', caddy_config, '--adapter', 'caddyfile']),
        ):
            with (root / f'{name}.log').open('w') as log:
                processes.append(subprocess.Popen(args, env=env, stdout=log, stderr=log))
        deadline = time.monotonic() + 20
        while True:
            try:
                request('/cal/ping', 200)
                request('/.well-known/openid-configuration', 200)
                break
            except (URLError, AssertionError):
                if time.monotonic() >= deadline or any(p.poll() is not None for p in processes):
                    raise
                time.sleep(.15)

        plain = f'http://127.0.0.1:{root_port}'
        assert request(plain + '/', 303)[0]['Location'] == '/frontend'
        request(plain + '/frontend/login', 200)
        request(plain + '/.well-known/caldav', 308)
        request(plain + '/cal/ping', 404)
        request(f'http://127.0.0.1:{root_port}/ping/', 200)
        run(rustical, '-c', cal_config, 'health', env=env)
        for path in ('/cal', '/cal/'):
            assert request(path, 303)[0]['Location'] == '/cal/frontend'
        for agent, endpoint in [('DAV test', 'caldav'), ('accountsd', 'caldav-compat')]:
            assert request('/.well-known/caldav', 308, headers={'User-Agent': agent})[0]['Location'] == '/cal/' + endpoint
        assert request('/.well-known/carddav', 308)[0]['Location'] == '/cal/carddav'
        print('PASS: default root and prefixed routes; discovery and health check')

        login = '/cal/frontend/login'
        headers, page = request(login, 200)
        assert b'action="/cal/frontend/login/oidc"' in page
        request('/cal/frontend/assets/style.css', 200)
        form(login, 405, username=USER, password=password)
        target = f'/cal/frontend/user/{USER}/calendar'
        _, body = request(target, 401)
        assert f'{login}?redirect_uri='.encode() in body
        headers, _ = form(login + '/oidc', 303, redirect_uri=target)
        authorize = headers['Location']
        assert parse_qs(urlsplit(authorize).query)['redirect_uri'] == [origin + login + '/oidc/callback']
        assert 'Path=/cal/' in headers['Set-Cookie']
        auth('/api/firstfactor', username=USER, password=password)
        first_headers, _ = request(authorize, 303)
        assert 'code' not in parse_qs(urlsplit(first_headers['Location']).query)
        auth('/api/secondfactor/totp', token=totp(totp_secret))
        callback = request(authorize, 303)[0]['Location']
        assert urlsplit(callback).path == login + '/oidc/callback'
        assert request(callback, 303)[0]['Location'] == target
        request(target, 200)
        print('PASS: Authelia OIDC requires TOTP and returns to the prefixed frontend')

        profile = f'/cal/frontend/user/{USER}'
        _, page = request(profile, 200, headers={'User-Agent': 'Android'})
        assert b'intent://localhost.localdomain' in page and b'/cal#Intent' in page
        assert b'src="/cal/frontend/assets/js/bundle.mjs"' in page
        _, bundle = request('/cal/frontend/assets/js/bundle.mjs', 200)
        assert b'appUrl(`/frontend/user/' in bundle
        first = form(profile + '/app_token', 200, name='phone')[1].decode()
        second = form(profile + '/app_token', 200, name='laptop')[1].decode()
        apple = form(profile + '/app_token', 200, name='apple', apple='true')[1]
        assert (origin + '/cal/caldav-compat/principal/' + USER).encode() in apple
        assert (origin + '/cal/carddav/principal/' + USER).encode() in apple
        flow = json.loads(form('/cal/index.php/login/v2', 200)[1])
        assert urlsplit(flow['login']).path.startswith('/cal/index.php/login/v2/flow/')
        assert urlsplit(flow['poll']['endpoint']).path.startswith('/cal/index.php/login/v2/poll/')
        request(flow['login'], 200)
        form(flow['login'], 200, app_name='native flow')
        assert json.loads(form(flow['poll']['endpoint'], 200, token=flow['poll']['token'])[1])['server'] == origin + '/cal'

        principal = f'/cal/caldav/principal/{USER}'
        propfind = b'''<D:propfind xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
            <D:prop><D:current-user-principal/><C:calendar-home-set/></D:prop></D:propfind>'''
        for token in (first, second):
            _, body = request(principal, 207, 'PROPFIND', propfind,
                              {**basic(token), 'Depth': '0'}, opener=clean)
            hrefs = [node.text for node in ET.fromstring(body).iter('{DAV:}href')]
            assert hrefs and all(href.startswith('/cal/caldav/') for href in hrefs), hrefs
        request(principal, 401, 'PROPFIND', headers=basic(password), opener=clean)
        request(principal, 401, 'PROPFIND', opener=clean)
        calendar = principal + '/test'
        request(calendar, 201, 'MKCALENDAR', b'''<C:mkcalendar xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
            <D:set><D:prop><D:displayname>Trial</D:displayname></D:prop></D:set></C:mkcalendar>''',
            {**basic(first), 'Content-Type': 'application/xml'}, opener=clean)
        event = calendar + '/trial.ics'
        ics = ('BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Trial//EN\r\nBEGIN:VEVENT\r\n'
               'UID:trial\r\nDTSTAMP:20261001T000000Z\r\nDTSTART:20261001T130000Z\r\n'
               'DTEND:20261001T140000Z\r\nSUMMARY:Trial event\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n').encode()
        request(event, 201, 'PUT', ics, {**basic(first), 'Content-Type': 'text/calendar'}, opener=clean)
        assert b'Trial event' in request(event, 200, headers=basic(second), opener=clean)[1]
        _, body = request(calendar, 207, 'PROPFIND', headers={**basic(second), 'Depth': '1'}, opener=clean)
        assert event.encode() in body
        request(event, 201, 'PUT', ics.replace(b'Trial event', b'Changed'),
                {**basic(second), 'Content-Type': 'text/calendar'}, opener=clean)
        assert b'Changed' in request(event, 200, headers=basic(first), opener=clean)[1]
        _, page = request(target, 200)
        assert f'action="{calendar}"'.encode() in page
        _, page = request(profile, 200)
        token_id = next(value for value in re.findall(rb'/app_token/([^"/]+)/delete', page)
                        if value.startswith(first.split('_', 1)[0].encode()))
        assert form(profile + f'/app_token/{token_id.decode()}/delete', 303)[0]['Location'] == '/cal/frontend/user'
        request(event, 401, headers=basic(first), opener=clean)
        request(event, 200, headers=basic(second), opener=clean)
        request(event, 200, 'DELETE', headers=basic(second), opener=clean)
        request(event, 404, headers=basic(second), opener=clean)
        print('PASS: frontend links, client setup URLs, DAV operations and independent app-password revocation')
    except BaseException:
        for name in ('root', 'cal', 'auth', 'caddy'):
            log = root / f'{name}.log'
            if log.exists():
                # URLs in logs may include one-use codes; all credentials belong to this disposable fixture.
                print(f'--- {name} ---\n{log.read_text()[-2500:]}')
        raise
    finally:
        for process in reversed(processes):
            if process.poll() is None:
                process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rustical', help='Absolute path to the packaged Rustical binary')
    args = parser.parse_args()
    assert socket.gethostbyname(HOST) == '127.0.0.1', f'{HOST} must resolve to loopback'
    with tempfile.TemporaryDirectory(prefix='rustical-test-') as temporary:
        check(args.rustical, Path(temporary))
