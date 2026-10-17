# Everything derived from the server's user registry:
#   ~/Gist/Vault/server/users.nix
#
# That one file is the only list of people, so adding a guest is one entry there
# and nothing in this repo. It is interpreted here once, for both consumers:
#   - teams: each non-"admins" group. Its members get, and only get
#       https://xieby1.cn/repos/<name>/…   (Authelia group "<name>"; the path
#       rule in ../authelia/default.nix is the whole web-side boundary)
#       read-only git for ~/Repos/<name> (enforced by ../caddy/cgit/ssh/default.nix)
#   - adminKeys: the ssh keys of the "admins" users, for a normal login shell
#     ../authelia/default.nix generates Authelia's user database from the same
#     file (with the ssh keys stripped).
#
# A missing or malformed registry fails evaluation of the whole home-manager
# configuration; that is deliberate, the alternatives are silent empty rules.
{
  lib,
  # Overridable so ../tests/guest-groups can run against a fixture.
  usersFile ? ~/Gist/Vault/server/users.nix,
  reposDir ? ~/Repos,
}:
let
  users = import usersFile;
  everyone = builtins.attrValues users;
  keyed = u: u.sshKeys or [ ];
  hasGroup = name: u: builtins.elem name (u.groups or [ ]);

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
assert builtins.any (hasGroup "admins") everyone;
{
  adminKeys = lib.concatMap keyed (builtins.filter (hasGroup "admins") everyone);
  teams = map (name: {
    inherit name;
    # Keys of every user in the group, so one key can cover several teams.
    sshKeys = lib.concatMap keyed (builtins.filter (hasGroup name) everyone);
  }) teams;
}
