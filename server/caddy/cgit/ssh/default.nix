# Root's SSH access for this server.
#
# - The owner key gets a normal login shell (also usable for git).
# - Keys in guestKeys are forced through restricted-git-ssh: read-only git
#   plumbing only, limited to repos under reposDir. No shell, no push, no
#   port/agent/X11 forwarding.
{ config, pkgs, lib, ... }:
let
  reposDir = "${config.home.homeDirectory}/Repos";

  # Forced command for guest keys. Parses the command line safely (shlex),
  # resolves the repo path (realpath), requires it under reposDir, then execs
  # git-upload-pack/git-upload-archive directly. Python is used because doing
  # this correctly in shell means fighting git's argument quoting.
  restrictedGitSsh = pkgs.writeScriptBin "restricted-git-ssh" ''
    #!${pkgs.python3}/bin/python3
    import os
    import shlex
    import sys

    REPOS = os.path.realpath("${reposDir}")
    ALLOWED = {
        "git-upload-pack": "${pkgs.git}/bin/git-upload-pack",
        "git-upload-archive": "${pkgs.git}/bin/git-upload-archive",
    }

    args = shlex.split(os.environ.get("SSH_ORIGINAL_COMMAND", ""))
    if len(args) != 2 or args[0] not in ALLOWED:
        sys.exit("read-only git access only")

    # Join against $HOME so both `ssh://host/root/Repos/x.git` (absolute) and
    # `host:Repos/x.git` (relative to home) forms land in the same place.
    repo = os.path.realpath(os.path.join("${config.home.homeDirectory}", args[1]))
    if repo != REPOS and not repo.startswith(REPOS + os.sep):
        sys.exit("access limited to " + REPOS)

    os.execv(ALLOWED[args[0]], [args[0], repo])
  '';

  # The owner's key: full login shell plus git. Kept in the vault so there is
  # one source of truth (same pattern as sys/default.nix).
  ownerKeys = [ (lib.trim (builtins.readFile ~/Gist/Vault/id_rsa.pub)) ];

  # Guest keys: clone only, restricted to reposDir. One key per element, e.g.
  #   "ssh-ed25519 AAAA... alice@laptop"
  guestKeys = [
  ];

  authorizedKeys = pkgs.writeText "authorized_keys" (
    lib.concatMapStrings (k: "${k}\n") ownerKeys
    + lib.concatMapStrings
      (k: ''command="${config.home.homeDirectory}/.nix-profile/bin/restricted-git-ssh",no-port-forwarding,no-agent-forwarding,no-pty,no-X11-forwarding ${k}'' + "\n")
      guestKeys
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
