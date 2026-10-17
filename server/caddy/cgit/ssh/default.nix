# Root's SSH access for this server.
#
# - The owner key gets a normal login shell (also usable for git).
# - Keys in guestKeys are forced through restricted-git-ssh: read-only git
#   plumbing only, limited to repos under reposDir. No shell, no push, no
#   port/agent/X11 forwarding.
{ config, pkgs, lib, ... }:
let
  reposDir = "${config.home.homeDirectory}/Repos";
  guestGroups = import ../../../guest-groups.nix { inherit lib; };

  # Forced command for guest keys. Parses the command line safely (shlex),
  # resolves the repo path (realpath), requires it under the root given as
  # argv[1] (set per key below), then execs git-upload-pack/git-upload-archive
  # directly. Python is used because doing this correctly in shell means
  # fighting git's argument quoting.
  restrictedGitSsh = pkgs.writeScriptBin "restricted-git-ssh" ''
    #!${pkgs.python3}/bin/python3
    import os
    import shlex
    import sys

    # argv[1] is mandatory: a missing root must fail, not default to all of
    # ~/Repos (every generated authorized_keys line passes one).
    if len(sys.argv) < 2:
        sys.exit("restricted-git-ssh: no repo root given by authorized_keys")
    REPOS = os.path.realpath(sys.argv[1])
    ALLOWED = {
        "git-upload-pack": "${pkgs.git}/bin/git-upload-pack",
        "git-upload-archive": "${pkgs.git}/bin/git-upload-archive",
    }

    args = shlex.split(os.environ.get("SSH_ORIGINAL_COMMAND", ""))
    if len(args) != 2 or args[0] not in ALLOWED:
        sys.exit("read-only git access only")

    # Join against $HOME so both `ssh://host/root/Repos/x.git` (absolute) and
    # `host:Repos/x.git` / `ssh://host/~/Repos/x.git` forms land in one place.
    path = args[1][2:] if args[1].startswith("~/") else args[1]
    repo = os.path.realpath(os.path.join("${config.home.homeDirectory}", path))
    if repo != REPOS and not repo.startswith(REPOS + os.sep):
        sys.exit("access limited to " + REPOS)

    os.execv(ALLOWED[args[0]], [args[0], repo])
  '';

  # Restriction applied to every guest key: read-only git, no shell, no
  # port/agent/X11 forwarding, no pty.
  guestRestrictions =
    "no-port-forwarding,no-agent-forwarding,no-pty,no-X11-forwarding";
  guestLine = root: k:
    ''command="${config.home.homeDirectory}/.nix-profile/bin/restricted-git-ssh ${root}",${guestRestrictions} ${k}'';

  # The owner's key: full login shell plus git. Kept in the vault so there is
  # one source of truth (same pattern as sys/default.nix).
  ownerKeys = [ (lib.trim (builtins.readFile ~/Gist/Vault/id_rsa.pub)) ];

  # Guest keys are `sshKeys` in ~/Gist/Vault/server/users.jsonc, one entry per
  # user, scoped to that user's team folders by ../../../guest-groups.nix. There
  # is no second list here: ssh access comes from the registry alone.

  authorizedKeys = pkgs.writeText "authorized_keys" (
    lib.concatMapStrings (k: "${k}\n") ownerKeys
    + lib.concatMapStrings (g:
      lib.concatMapStrings (k: "${guestLine "${reposDir}/${g.name}" k}\n") g.sshKeys)
      guestGroups
  );
in {
  home.packages = [ restrictedGitSsh ];

  # sshd's StrictModes (default yes) refuses an authorized_keys symlinked into
  # /nix/store, since /nix/store is group-writable. Copy it into a real 0600
  # file instead of using home.file.
  home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "$HOME/.ssh"
    $DRY_RUN_CMD chmod 700 "$HOME/.ssh"
    $DRY_RUN_CMD install -m 600 ${authorizedKeys} "$HOME/.ssh/authorized_keys"
  '';
}
