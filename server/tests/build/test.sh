#!/usr/bin/env bash
# Builds the server configuration with a fake $HOME (see home.nix) and checks
# the vault stayed out of the store: authelia's user database must be a plain
# path, and no argon2 hash may appear in the generated config. A path value
# interpolated as a string (`"${~/…}"`) silently copies the whole directory
# into /nix/store, which is world-readable.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
home-manager -f "$here/home.nix" build >/dev/null
gen=$(readlink -f result)
cfg=$(grep -RhoIE '/nix/store/[a-z0-9]+-authelia-configuration\.yml' "$gen" | head -1)
if [ -z "$cfg" ]; then
  echo "FAIL: no generated authelia config under $gen"
  exit 1
fi
users=$(grep -oE 'path: .*users\.jsonc' "$cfg" | head -1)
case "$users" in
*"/nix/store/"*)
  echo "FAIL: the user registry was copied into the store: $users"
  exit 1
  ;;
esac
if grep -q argon2id "$cfg"; then
  echo "FAIL: a password hash reached the generated config"
  exit 1
fi
echo "ok: server build"
