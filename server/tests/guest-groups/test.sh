#!/usr/bin/env bash
# Checks server/guest-groups.nix against a throwaway registry and a throwaway
# ~/Repos: which teams exist, whose keys land where, that the admins' keys stay
# out of the team-scoped lines, that no password leaks into the result, and that
# the three asserts fire.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/Repos/BTeam" "$tmp/Repos/ATeam"

eval_gg() { # $1 = registry file, $2 = repos dir
  nix-instantiate --eval --strict --json \
    --expr "let pkgs = import <nixpkgs> { }; in
           import $root/server/guest-groups.nix {
             lib = pkgs.lib; usersFile = \"$1\"; reposDir = \"$2\";
           }"
}

fails() { # $1 = registry file, $2 = repos dir, $3 = what should fail
  if eval_gg "$1" "$2" >/dev/null 2>&1; then
    echo "FAIL: $3 was accepted"
    exit 1
  fi
}

cat >"$tmp/ok.nix" <<'EOF'
{
  owner = {
    password = "SECRET-OWNER";
    groups = [ "admins" ];
    sshKeys = [ "ssh-ed25519 AAAA owner" ];
  };
  alice = {
    password = "SECRET-ALICE";
    groups = [ "BTeam" ];
    sshKeys = [ "ssh-ed25519 AAAA alice" ];
  };
  bob = {
    password = "SECRET-BOB";
    groups = [ "BTeam" "ATeam" ];
    sshKeys = [ "ssh-ed25519 AAAA bob" ];
  };
}
EOF

out=$(eval_gg "$tmp/ok.nix" "$tmp/Repos")
want='{"adminKeys":["ssh-ed25519 AAAA owner"],"teams":[{"name":"BTeam","sshKeys":["ssh-ed25519 AAAA alice","ssh-ed25519 AAAA bob"]},{"name":"ATeam","sshKeys":["ssh-ed25519 AAAA bob"]}]}'
if [ "$out" != "$want" ]; then
  echo "FAIL: derived admins/teams/keys"
  echo "  want: $want"
  echo "  got:  $out"
  exit 1
fi
case "$out" in
*SECRET*)
  echo "FAIL: a password reached the derived data"
  exit 1
  ;;
esac

sed 's/"ATeam"/"A.Team"/' "$tmp/ok.nix" >"$tmp/bad-name.nix"
fails "$tmp/bad-name.nix" "$tmp/Repos" "a team name with a dot"

sed 's/"ATeam"/"NoSuchTeam"/' "$tmp/ok.nix" >"$tmp/no-folder.nix"
fails "$tmp/no-folder.nix" "$tmp/Repos" "a team without a folder under ~/Repos"

sed 's/\[ "admins" \]/[ ]/' "$tmp/ok.nix" >"$tmp/no-admin.nix"
fails "$tmp/no-admin.nix" "$tmp/Repos" "a registry with no admins group"

echo "ok: guest-groups"
