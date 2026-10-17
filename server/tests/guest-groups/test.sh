#!/usr/bin/env bash
# Checks the derivation in server/guest-groups.nix against a throwaway vault and
# a throwaway ~/Repos: which teams exist, whose keys land on which team, that
# the password hash never escapes, and that the three asserts fire.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/Repos/BTeam" "$tmp/Repos/ATeam"

eval_gg() { # $1 = users file, $2 = repos dir
  nix-instantiate --eval --strict --json \
    --expr "let pkgs = import <nixpkgs> { }; in
           import $root/server/guest-groups.nix {
             lib = pkgs.lib; usersFile = \"$1\"; reposDir = \"$2\";
           }"
}

fails() { # $1 = users file, $2 = repos dir, $3 = what should fail
  if eval_gg "$1" "$2" >/dev/null 2>&1; then
    echo "FAIL: $3 was accepted"
    exit 1
  fi
}

cat >"$tmp/ok.jsonc" <<'EOF'
# whole-line comment: must be ignored
{
  # indented comment, also ignored
  "users": {
    "owner": { "password": "SECRET-OWNER", "groups": ["admins"], "sshKeys": ["ssh-ed25519 AAAA owner"] },
    "alice": { "password": "SECRET-ALICE", "groups": ["BTeam"], "sshKeys": ["ssh-ed25519 AAAA alice"] },
    "bob":   { "password": "SECRET-BOB", "groups": ["BTeam", "ATeam"], "sshKeys": ["ssh-ed25519 AAAA bob"] }
  }
}
EOF

out=$(eval_gg "$tmp/ok.jsonc" "$tmp/Repos")
want='[{"name":"BTeam","sshKeys":["ssh-ed25519 AAAA alice","ssh-ed25519 AAAA bob"]},{"name":"ATeam","sshKeys":["ssh-ed25519 AAAA bob"]}]'
if [ "$out" != "$want" ]; then
  echo "FAIL: derived teams/keys"
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

sed 's/"BTeam", "ATeam"/"B.Team"/' "$tmp/ok.jsonc" >"$tmp/bad-name.jsonc"
fails "$tmp/bad-name.jsonc" "$tmp/Repos" "a team name with a dot"

sed 's/"BTeam", "ATeam"/"NoSuchTeam"/' "$tmp/ok.jsonc" >"$tmp/no-folder.jsonc"
fails "$tmp/no-folder.jsonc" "$tmp/Repos" "a team without a folder under ~/Repos"

sed 's/\["admins"\]/[]/' "$tmp/ok.jsonc" >"$tmp/no-admin.jsonc"
fails "$tmp/no-admin.jsonc" "$tmp/Repos" "a registry with no admins group"

echo "ok: guest-groups"
