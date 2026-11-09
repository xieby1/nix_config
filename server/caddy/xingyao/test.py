#!/usr/bin/env python3
"""Test generated deployment config locally with disposable users, TOTP and data.

Run: nix-shell -p python3Packages.pyyaml caddy authelia --run 'python3 server/caddy/xingyao/test.py'
No server SSH, activation, real login credentials or owner data are used.
Fetching the source pin may use the building user's GitHub SSH access.
"""
import base64
import hashlib
import hmac
import http.client
import json
import os
from pathlib import Path
import secrets
import shutil
import socket
import ssl
import struct
import subprocess
import tempfile
import time

import yaml

HERE = Path(__file__).resolve().parent
PREFIX = '/BTeam/XingYao'
IDENTITY = ('Remote-User', 'Remote-Name', 'Remote-Email', 'Remote-Groups')


def run(*args, **kwargs):
    return subprocess.check_output(args, text=True, **kwargs).strip()


def port():
    with socket.socket() as sock:
        sock.bind(('127.0.0.1', 0))
        return sock.getsockname()[1]


class LocalHTTPS(http.client.HTTPSConnection):
    def connect(self):
        sock = socket.create_connection(('127.0.0.1', self.port), self.timeout)
        self.sock = self._context.wrap_socket(sock, server_hostname=self.host)


def request(number, path, headers=None, payload=None):
    conn = LocalHTTPS('xieby1.cn', number, context=ssl._create_unverified_context(), timeout=10)
    try:
        headers = dict(headers or {})
        if payload is not None:
            headers['Content-Type'] = 'application/json'
        conn.request('POST' if payload is not None else 'GET', path,
                     body=json.dumps(payload) if payload is not None else None, headers=headers)
        response = conn.getresponse()
        return response.status, dict(response.getheaders()), response.read()
    finally:
        conn.close()


def main():
    authelia, caddy = shutil.which('authelia'), shutil.which('caddy')
    assert authelia and caddy, 'Run inside the documented nix-shell'
    processes = []
    with tempfile.TemporaryDirectory(prefix='xingyao-deployment-') as temporary:
        root = Path(temporary)
        # Nix ~ paths resolve under this HOME, never under the owner's vault.
        env = dict(os.environ, HOME=str(root), XDG_CACHE_HOME=os.environ.get('XDG_CACHE_HOME', str(Path.home() / '.cache')))
        vault = root / 'Gist/Vault/server'
        vault.mkdir(parents=True)
        for group in ('BTeam', 'ATeam'):
            (root / 'Repos' / group).mkdir(parents=True)
        password = secrets.token_urlsafe(24)
        digest = run(authelia, 'crypto', 'hash', 'generate', 'argon2', '--password', password).split('Digest: ')[1]
        users = {'editor': 'BTeam', 'owner': 'admins', 'outsider': 'ATeam'}
        (vault / 'users.nix').write_text('{ lib }: {\n' + '\n'.join(
            f'{name} = {{ displayname = "{name} Name"; password = {json.dumps(digest)}; email = "{name}@example.invalid"; groups = [ "{group}" ]; sshKeys = []; }};'
            for name, group in users.items()) + '\n}\n')
        metadata_path = run('nix-build', str(HERE / 'test.nix'), '--no-out-link', env=env)
        metadata = json.loads(Path(metadata_path).read_text())
        unit = metadata['xingyao']
        assert unit['Install']['WantedBy'] == ['default.target']
        assert '"XINGYAO_PORT=3004"' in unit['Service']['Environment']
        assert '"XINGYAO_BASE_PATH=/BTeam/XingYao/"' in unit['Service']['Environment']
        assert f'"XINGYAO_DATA_ROOT={root}/Repos/BTeam/XingYaoData"' in unit['Service']['Environment']
        binary, = unit['Service']['ExecStart']
        pre_start = unit['Service']['ExecStartPre']
        configuration = yaml.safe_load(Path(metadata['autheliaConfig']).read_text())
        rules = configuration['access_control']['rules']
        rule = next(rule for rule in rules if '^/BTeam/XingYao(/.*)?$' in rule.get('resources', []))
        assert rule['subject'] == ['group:BTeam', 'group:admins'] and rule['policy'] == 'two_factor'
        assert configuration['access_control']['default_policy'] == 'deny'
        assert 'sshKeys' not in Path(configuration['authentication_backend']['file']['path']).read_text()
        auth_port, api_port, proxy_port = port(), port(), port()
        origin = f'https://xieby1.cn:{proxy_port}'
        configuration['server']['address'] = f'tcp://127.0.0.1:{auth_port}/'
        configuration['session']['secret'] = secrets.token_hex(32)
        configuration['session']['cookies'][0]['authelia_url'] = origin
        configuration['storage']['encryption_key'] = secrets.token_hex(32)
        configuration['storage']['local']['path'] = str(root / 'auth.sqlite')
        configuration['notifier']['filesystem']['filename'] = str(root / 'notifications.txt')
        configuration['identity_validation'] = {'reset_password': {'jwt_secret': secrets.token_hex(32)}}
        config_path = root / 'authelia.yml'
        config_path.write_text(yaml.safe_dump(configuration))
        run(authelia, '--config', str(config_path), 'config', 'validate')
        for group, path, expected in [
            ('BTeam', PREFIX, 'two_factor'), ('BTeam', PREFIX + '/api/nodes', 'two_factor'),
            ('admins', PREFIX + '/', 'two_factor'), ('ATeam', PREFIX + '/', 'deny'),
            ('BTeam', PREFIX + 'Other/', 'deny'), ('BTeam', '/BTeam/', 'deny'),
            ('BTeam', '/bteam/xingyao/', 'deny'), ('BTeam', '/sixu/', 'deny'),
        ]:
            policy = run(authelia, '--config', str(config_path), 'access-control', 'check-policy',
                         '--url', origin + path, '--username', 'fixture', '--groups', group)
            assert f"policy '{expected}'" in policy, policy
        data = root / 'data'
        git_env = dict(env, GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL='/dev/null',
                       GIT_CONFIG_COUNT='2', GIT_CONFIG_KEY_0='user.name', GIT_CONFIG_VALUE_0='Fixture',
                       GIT_CONFIG_KEY_1='user.email', GIT_CONFIG_VALUE_1='fixture@example.invalid')
        run(pre_start, env=dict(git_env, XINGYAO_DATA_ROOT=str(data)))
        initial = run('git', '-C', str(data), 'rev-parse', 'HEAD')
        run(pre_start, env=dict(git_env, XINGYAO_DATA_ROOT=str(data)))
        assert run('git', '-C', str(data), 'rev-parse', 'HEAD') == initial
        route = metadata['route'].replace('127.0.0.1:9091', f'127.0.0.1:{auth_port}').replace('127.0.0.1:3004', f'127.0.0.1:{api_port}')
        caddy_path = root / 'Caddyfile'
        caddy_path.write_text(f'''{{
  admin off
  auto_https disable_redirects
  skip_install_trust
}}
{origin} {{
  bind 127.0.0.1
  tls internal
  {route}
  reverse_proxy 127.0.0.1:{auth_port}
}}
''')
        def start(command, environment):
            log = tempfile.TemporaryFile()
            process = subprocess.Popen(command, env=environment, stdout=log, stderr=log)
            processes.append((process, log))
            return process
        try:
            start([authelia, '--config', str(config_path)], env)
            start([binary], dict(git_env, XINGYAO_DATA_ROOT=str(data), XINGYAO_PORT=str(api_port), XINGYAO_BASE_PATH=PREFIX + '/'))
            start([caddy, 'run', '--config', str(caddy_path), '--adapter', 'caddyfile'],
                  dict(env, XDG_CONFIG_HOME=str(root / 'config'), XDG_DATA_HOME=str(root / 'share')))
            for _ in range(100):
                assert all(process.poll() is None for process, _ in processes), 'fixture process exited'
                try:
                    if request(proxy_port, PREFIX + '/api/me')[0] == 401:
                        break
                except OSError:
                    pass
                time.sleep(.1)
            else:
                raise AssertionError('fixtures did not become ready')
            spoof = {key: 'attacker' for key in IDENTITY}
            for path in ('', '/', '/api/me', '/api/nodes', '/api/assets/missing.js', '/sources/main.ncl'):
                status, _, _ = request(proxy_port, PREFIX + path, spoof)
                assert status == 401, (path, status)
            cookies = {}
            for username in users:
                secret = base64.b32encode(secrets.token_bytes(32)).decode().rstrip('=')
                run(authelia, '--config', str(config_path), 'storage', 'user', 'totp', 'generate', username, '--secret', secret)
                status, headers, body = request(proxy_port, '/api/firstfactor', payload={'username': username, 'password': password})
                assert status == 200, (username, status, body)
                cookie = headers['Set-Cookie'].split(';', 1)[0]
                assert request(proxy_port, PREFIX + '/api/me', dict(spoof, Cookie=cookie))[0] in (401, 403)
                counter = struct.pack('>Q', int(time.time()) // 30)
                digest = hmac.new(base64.b32decode(secret + '=' * (-len(secret) % 8)), counter, hashlib.sha1).digest()
                offset = digest[-1] & 15
                token = str((struct.unpack('>I', digest[offset:offset+4])[0] & 0x7fffffff) % 1000000).zfill(6)
                status, headers, body = request(proxy_port, '/api/secondfactor/totp', {'Cookie': cookie}, {'token': token})
                assert status == 200, (username, status, body)
                cookies[username] = headers.get('Set-Cookie', cookie).split(';', 1)[0]
            for username in ('editor', 'owner'):
                status, _, body = request(proxy_port, PREFIX + '/api/me', dict(spoof, Cookie=cookies[username]))
                assert status == 200 and json.loads(body) == {
                    'username': username, 'name': username + ' Name', 'email': username + '@example.invalid',
                }, (username, status, body)
            assert request(proxy_port, PREFIX + '/api/me', dict(spoof, Cookie=cookies['outsider']))[0] == 403
            headers = dict(spoof, Cookie=cookies['editor'])
            status, redirected, _ = request(proxy_port, PREFIX, headers)
            assert status == 308 and redirected['Location'] == PREFIX + '/', (status, redirected)
            for path in (PREFIX + 'Other/api/me', '/BTeam/api/me', '/api/me'):
                status, _, body = request(proxy_port, path, headers)
                assert not (status == 200 and b'editor Name' in body), (path, status, body)
            status, _, body = request(proxy_port, PREFIX + '/graphs/sample-project/composed', headers)
            assert status == 200
            asset = body.decode().split('src="')[1].split('"')[0]
            assert asset.startswith(PREFIX + '/api/assets/')
            assert request(proxy_port, asset, headers)[0] == 200
            status, _, body = request(proxy_port, PREFIX + '/api/nodes', headers)
            assert status == 200
            revision = json.loads(body)['revision']
            intent = {'revision': revision, 'creation': {'parent': '@/', 'path': 'local-auth-test', 'kind': 'capability', 'name': {'mode': 'text', 'value': 'Local test'}}}
            for extra in ({}, {'Origin': 'https://evil.example.test'}):
                assert request(proxy_port, PREFIX + '/api/node-creation', dict(headers, **extra), intent)[0] == 403
            status, _, body = request(proxy_port, PREFIX + '/api/node-creation', dict(headers, Origin=origin), intent)
            assert status == 200 and json.loads(body)['target'] == '@/local-auth-test', (status, body)
            author = run('git', '-C', str(data), 'log', '-1', '--format=%an <%ae>|%cn <%ce>')
            assert author == 'editor Name <editor@example.invalid>|XingYao <server@xingyao.invalid>', author
            assert request(proxy_port, PREFIX + '/api/unknown', headers)[0] == 404
            assert not run('git', '-C', str(data), 'status', '--porcelain')
            print('PASS: Home Manager sample initialization and repeat-start preservation; Caddy/Authelia BTeam/admins 2FA; outsider/1FA/spoof denial; prefixed assets; CSRF; attributed creation')
        except BaseException:
            for _, log in processes:
                log.seek(0)
                print(log.read().decode(errors='replace')[-4000:])
            raise
        finally:
            for process, log in reversed(processes):
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill(); process.wait()
                log.close()


if __name__ == '__main__':
    main()
