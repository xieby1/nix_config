{ config, lib, pkgs, ... }: {
  home.packages = [
    pkgs.sshfs
  ];
  programs.ssh.enable = true;
  programs.ssh.includes = lib.optional (builtins.pathExists ~/Gist/Config/ssh.conf) "~/Gist/Config/ssh.conf";
  # For compatibility
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks."*" = {
    forwardAgent = false;
    addKeysToAgent = "no";
    compression = false;
    serverAliveInterval = 0;
    serverAliveCountMax = 3;
    hashKnownHosts = false;
    userKnownHostsFile = "~/.ssh/known_hosts";
    controlMaster = "no";
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "no";
  };
  programs.bash.bashrcExtra = lib.optionalString config.isNixOnDroid ''
    # start sshd
    if [[ -z "$(pidof sshd-start)" ]]; then
        tmux new -d -s sshd-start sshd-start
    fi
  '';
}
