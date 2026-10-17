# Guest teams: one entry per team folder under ~/Repos, e.g. ~/Repos/BTeam.
#
# Guests of a team get, and only get:
#   - https://xieby1.cn/repos/<name>/…   (Authelia group "<name>", see
#     ../authelia/default.nix; the path rule is the whole web-side boundary)
#   - read-only git over ssh for repos under ~/Repos/<name> (sshKeys below,
#     enforced by ../caddy/cgit/ssh/default.nix)
# Adding a team is one entry here.
let
  teams = [
    {
      # Folder under ~/Repos; also the URL segment.
      name = "BTeam";

      # Read-only clone keys, limited to ~/Repos/<name>. Not secret, so they
      # live here with the team they belong to.
      sshKeys = [
        # "ssh-ed25519 AAAA... alice@laptop"
      ];
    }
  ];
in
# The name ends up in an Authelia regex (^/repos/<name>(/.*)?$) and on the
# forced-command line in authorized_keys, both of which read more than a path
# segment: a "." would match any character (team A.B also matching /repos/AXB/)
# and a space would split the ssh command's argument list. Keep names plain.
assert builtins.all (g: builtins.match "[A-Za-z0-9_-]+" g.name != null) teams;
# The team name is also the Authelia group, so it must not shadow the owner
# group that grants /sixu, /web and the portal.
assert builtins.all (g: g.name != "admins") teams;
teams
