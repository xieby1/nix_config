# Rustical base-path patch

`package.nix` applies `base-path.patch` to `pkgs.rustical` (based on 0.16.7). The patch implements the subpath deployment described in [upstream issue #148](https://github.com/lennart-k/rustical/issues/148).

```toml
[http]
base_path = "/cal"
```

Omit `base_path` to keep root deployment. For `/cal`, the proxy must forward `/cal` and `/cal/*` without stripping the prefix. Host-root CalDAV/CardDAV discovery can be forwarded to Rustical's prefixed `/.well-known/caldav` and `/.well-known/carddav` paths. The OIDC redirect URI is `https://xieby1.cn/cal/frontend/login/oidc/callback`.

## Verify locally

From the Nix config root:

```sh
RUSTICAL="$(nix-build --no-out-link -E 'import ./server/rustical/package.nix { pkgs = import <nixpkgs> {}; }')/bin/rustical"
export RUSTICAL
nix-shell -p python3 openssl caddy authelia --run 'python3 server/rustical/test.py "$RUSTICAL"'
```

The integration test uses loopback only, with a temporary TLS CA, OIDC credentials and SQLite databases. `localhost.localdomain` must resolve to `127.0.0.1`. It exercises root and prefixed mounts, same-origin HTTPS routing, Authelia OIDC with TOTP, app-password revocation, and CalDAV event operations. It checks frontend responses and client setup URLs over HTTP, not through native client or browser UI automation.

## Rebase on an upgrade

Apply the patch to a clean checkout of the new packaged tag and review upstream changes for newly hardcoded root paths. If frontend source changes, regenerate `crates/frontend/public/assets/js/bundle.mjs` using upstream's `deno task build` in `crates/frontend/js-components`, and include that diff. The Nix package embeds the bundle rather than rebuilding it. Export the updated patch and rerun the build and local integration test before shipping.
