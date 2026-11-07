#!/usr/bin/env bash
# Builds the server configuration with a fake $HOME (see home.nix) and checks the
# generated authelia pieces: the user database is generated into the store from
# the vault registry (hashes there on purpose, see the vault file), while
# authelia.env stays a plain path. Interpolating a path value (`"${~/…}"`) would
# silently copy the whole vault directory into /nix/store.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
home-manager -f "$here/home.nix" build >/dev/null
gen=$(readlink -f result)
fail() {
  echo "FAIL: $1"
  exit 1
}

cfg=$(grep -RhoIE '/nix/store/[a-z0-9]+-authelia-configuration\.yml' "$gen" | head -1)
[ -n "$cfg" ] || fail "no generated authelia config under $gen"

db=$(grep -oE 'path: /nix/store/[a-z0-9]+-authelia-users\.yml' "$cfg" | head -1 | cut -d' ' -f2)
[ -n "$db" ] || fail "the user database is not generated into the store"
grep -q 'xieby1' "$db" || fail "the owner is missing from the generated user database"
grep -q 'sshKeys' "$db" && fail "sshKeys leaked into the generated user database"

env=$(sed -n 's/^EnvironmentFile=//p' "$gen/home-files/.config/systemd/user/authelia.service")
[ -n "$env" ] || fail "the authelia unit has no EnvironmentFile"
case "$env" in
/nix/store/*) fail "authelia.env is in the store: $env" ;;
esac

echo "ok: server build"
