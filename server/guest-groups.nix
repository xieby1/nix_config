# Guest teams, derived from the server's single user registry:
#   ~/Gist/Vault/server/users.jsonc
#
# That one file is both Authelia's user database (path set in
# ../authelia/default.nix) and the source of everything here, so adding a guest
# is one entry there and nothing in this repo. Guests of a team get, and only
# get:
#   - https://xieby1.cn/repos/<name>/…   (Authelia group "<name>"; the path rule
#     in ../authelia/default.nix is the whole web-side boundary)
#   - read-only git over ssh for repos under ~/Repos/<name> (sshKeys below,
#     enforced by ../caddy/cgit/ssh/default.nix)
#
# A missing or malformed vault file fails evaluation of the whole home-manager
# configuration; that is deliberate, the alternatives are silent empty rules.
{
  lib,
  # Overridable so ../tests/guest-groups can run against a fixture.
  usersFile ? ~/Gist/Vault/server/users.jsonc,
  reposDir ? ~/Repos,
}:
let
  # Read at eval time from outside the store: only non-secret fields are used
  # here, and the same file reaches authelia as a path string, so the argon2
  # hashes never end up in /nix/store.
  lines = builtins.filter builtins.isString (builtins.split "\n" (builtins.readFile usersFile));
  # JSON has no comments, so whole-line `#` ones are dropped before parsing.
  # Trailing comments are not supported on purpose: `#` also occurs inside
  # ssh-key strings, so cutting at the first `#` would corrupt data.
  body = builtins.concatStringsSep "\n"
    (builtins.filter (l: builtins.match "[[:space:]]*#.*" l == null) lines);

  # Passwords go away immediately, so nothing downstream can interpolate a hash.
  users = builtins.mapAttrs (_: u: builtins.removeAttrs u [ "password" ])
    (builtins.fromJSON body).users;

  everyone = builtins.attrValues users;

  # "admins" is the owner group, granted /sixu and /web by the rules in
  # ../authelia/default.nix; it is never a team.
  teams = builtins.filter (n: n != "admins")
    (lib.unique (lib.concatMap (u: u.groups or [ ]) everyone));
in
# The name ends up in an Authelia regex (^/repos/<name>(/.*)?$) and on the
# forced-command line in authorized_keys, both of which read more than a path
# segment: a "." would match any character (team A.B also matching /repos/AXB/)
# and a space would split the ssh command's argument list. Keep names plain.
assert builtins.all (n: builtins.match "[A-Za-z0-9_-]+" n != null) teams;
# A team is a folder under ~/Repos. Catching a typo here beats a guest who logs
# in and silently sees nothing.
assert builtins.all (n: builtins.pathExists (reposDir + "/${n}")) teams;
# Every access rule for the owner needs this group; without it nobody can reach
# the portal, /sixu or /web, and only a shell on the box can fix it.
assert builtins.any (u: builtins.elem "admins" (u.groups or [ ])) everyone;
map (name: {
  inherit name;
  # Keys of every user in the group, so one key can cover several teams.
  sshKeys = lib.concatMap (u: u.sshKeys or [ ])
    (builtins.filter (u: builtins.elem name (u.groups or [ ])) everyone);
}) teams
