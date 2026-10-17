#!/usr/bin/env bash
# Drives the real route fragment (server/caddy/cgit/caddy.nix) with real
# fcgiwrap+cgit, Authelia stubbed out. This is about the cgit side, which is
# where a URL can name a repo other than the one in the path:
#
#   - browsing a repo under a team folder works
#   - cloning it reaches git-http-backend, not cgit
#   - ?url=<other repo> is refused, so an allowed path cannot render another repo
#   - a cgit file view ending in info/refs is not hijacked by the clone route
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)

tmp=$(mktemp -d)
port_cgi=19507
port_http=19543
cleanup() { kill $(jobs -p) 2>/dev/null || true; rm -rf "$tmp"; }
trap cleanup EXIT

cgi=$(nix-build --no-out-link -E 'with import <nixpkgs> {}; fcgiwrap')
serve=$(nix-build --no-out-link -E 'with import <nixpkgs> {}; caddy')

mkdir -p "$tmp/repos/BTeam" "$tmp/cache" "$tmp/work/info"
git init -q --bare "$tmp/repos/BTeam/team.git"
git init -q --bare "$tmp/repos/owner.git"
echo refs > "$tmp/work/info/refs"
git -C "$tmp/work" init -q
git -C "$tmp/work" add -A
git -C "$tmp/work" -c user.email=t@t -c user.name=t commit -qm x
git -C "$tmp/work" push -q "$tmp/repos/BTeam/team.git" HEAD:refs/heads/main

# Same prefix the fragment serves under, so a rename of consts.prefix does not
# silently turn every check below into a 404.
prefix=$(nix-instantiate --eval --strict --raw \
  -E "import $root/server/caddy/cgit/consts.nix" -A prefix)
# Same for the stylesheet name, which the fragment and the head-include share.
theme_file=$(nix-instantiate --eval --strict --raw \
  -E "import $root/server/caddy/cgit/consts.nix" -A themeFile)

mkdir -p "$tmp/theme$(dirname "$theme_file")"
echo 'body{}' > "$tmp/theme$theme_file"
# Decoy next to the stylesheet: the theme route must not reach it.
echo 'root-title=leak' > "$tmp/theme/cgitrc"

printf 'virtual-root=%s/\ncache-root=%s/cache\nscan-path=%s/repos\n' \
  "$prefix" "$tmp" "$tmp" > "$tmp/cgitrc"

fragment=$(nix-instantiate --eval --strict --raw -E "
  (import $root/server/caddy/cgit/caddy.nix {
    inherit (import <nixpkgs> {}) cgit git;
    cgitrc = \"$tmp/cgitrc\";
    themeRoot = \"$tmp/theme\";
    reposPath = \"$tmp/repos\";
  })" | sed -e "s/9007/$port_cgi/g" -e '/^ *import auth$/d')

printf '{\n\tadmin off\n\tauto_https off\n}\n:%s {\n%s\n}\n' "$port_http" "$fragment" > "$tmp/Caddyfile"
caddy adapt --config "$tmp/Caddyfile" --adapter caddyfile > /dev/null 2>&1

"$cgi/bin/fcgiwrap" -c 4 -s "tcp:127.0.0.1:$port_cgi" > "$tmp/cgi.log" 2>&1 &
"$serve/bin/caddy" run --config "$tmp/Caddyfile" --adapter caddyfile > "$tmp/caddy.log" 2>&1 &
for _ in $(seq 100); do
  ss -ltn | grep -q ":$port_cgi " && ss -ltn | grep -q ":$port_http " && break
  sleep 0.1
done

fail=0
check() { # name expected actual
  if [[ "$3" == "$2" ]]; then echo "ok   $1"; else echo "FAIL $1: expected '$2', got '$3'"; fail=1; fi
}
get() { curl -s --noproxy '*' -o "$tmp/body" -w '%{http_code}' "http://127.0.0.1:$port_http$1"; }
ctype() { curl -s --noproxy '*' -o /dev/null -w '%{content_type}' "http://127.0.0.1:$port_http$1"; }

check "browse a team repo" 200 "$(get "$prefix/BTeam/team.git/")"
check "browse a team repo: right repo" yes "$(grep -q 'BTeam/team.git' "$tmp/body" && echo yes || echo no)"
check "browse the owner's repo" 200 "$(get "$prefix/owner.git/")"

check "clone a nested repo (info/refs)" 200 "$(get "$prefix/BTeam/team.git/info/refs?service=git-upload-pack")"
check "clone: git answers, not cgit" 001e "$(head -c 4 "$tmp/body")"

check "?url=<other repo> refused" 403 "$(get "$prefix/BTeam/team.git/?url=/owner.git")"
check "?url= refused (encoded key)" 403 "$(get "$prefix/BTeam/team.git/?%75rl=/owner.git")"
check "plain view of info/refs still served" 200 "$(get "$prefix/BTeam/team.git/plain/info/refs")"

check "theme stylesheet served" 200 "$(get "$prefix$theme_file")"
check "theme served from the theme root" yes "$(grep -q 'body{}' "$tmp/body" && echo yes || echo no)"
check "theme served as CSS" text/css "$(ctype "$prefix$theme_file" | cut -d';' -f1)"
check "rest of the theme tarball stays unreachable" 404 "$(get "$prefix/cgitrc")"

exit "$fail"
