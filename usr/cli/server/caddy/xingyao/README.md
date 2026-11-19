# XingYao proxy and local deployment test

The public path is `/BTeam/XingYao/`.
The sibling `caddy.nix` strips untrusted identity headers, authenticates the original path, then strips the prefix and proxies to `127.0.0.1:3004`.
Authelia allows `BTeam` or `admins` with two-factor authentication; both groups can edit the shared collection.
The Home Manager instance is configured in `../../xingyao/default.nix` and uses a server-local data repository, not an actively synchronized directory.
`initializeWithSamples = true` seeds a missing/empty directory before startup using the service user's configured Git identity; nonempty repositories are never rewritten.
This check runs on every start, so it can also reseed samples after data loss. Disable the option after first use if that is undesirable.
The GitHub source is pinned in `../../xingyao/sources.json` using SSH because anonymous archive downloads are unavailable; the building user's GitHub SSH access is required.

## Test locally without deploying

From the Nix configuration repository:

```sh
nix-shell -p python3Packages.pyyaml caddy authelia \
  --run 'python3 server/caddy/xingyao/test.py'
```

This evaluates the real XingYao and Authelia modules with Home Manager, builds the pinned application, and runs the exact Caddy route on temporary loopback ports.
It uses a temporary HOME, synthetic user registry, temporary TLS CA, randomly generated passwords/TOTP secrets, and a sample repository created by the generated service pre-start script.
Requests use the production hostname for Host/SNI but connect directly to loopback; DNS and the live server are never used.
It installs no certificates, activates no Home Manager generation, changes no services and removes its temporary data/processes afterward.
Nix build outputs and disposable password hashes remain in the Nix store as usual.

Checks include:

- Service environment, data path, public prefix, default-target startup, sample initialization and repeat-start preservation.
- Generated Authelia policy and database schema.
- Signed-out and password-only denial, successful BTeam/admins TOTP logins, and unrelated-group denial.
- Original-path authorization, neighboring/case-mismatched path policy, and forged identity rejection.
- Trailing-slash redirect, prefixed packaged assets and sample reads.
- Missing/foreign Origin denial and one authenticated mutation with correct Git authorship.

This is a focused deployment test, not a full server Home Manager build.
It intentionally avoids unrelated applications and does not read the real vault registry.
The full server build still requires all other pinned dependencies to be available.
