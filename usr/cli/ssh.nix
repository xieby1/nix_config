{ config, lib, pkgs, ... }: {
  home.packages = [
    pkgs.sshfs
  ];
  programs.ssh.enable = true;
  programs.ssh.includes = lib.optional (
    builtins.pathExists ~/Gist/Config/ssh.conf
    # SSH need ssh.conf are only writable for current user, while nix-on-droid cannot change the system folder's permissions.
    # So I disable inluding ssh.conf in nix-on-droid
    && !config.isNixOnDroid
  ) "~/Gist/Config/ssh.conf";
  # For compatibility
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks = {
    "*" = {
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
    # https://docs.github.com/zh/authentication/troubleshooting-ssh/using-ssh-over-the-https-port
    "github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      proxyCommand = "nc -X connect -x 127.0.0.1:${toString config.proxyPort} %h %p";
    };
  };
  programs.bash.bashrcExtra = lib.optionalString config.isNixOnDroid ''
    # start sshd
    if [[ -z "$(pidof sshd-start)" ]]; then
        tmux new -d -s sshd-start sshd-start
    fi
  '';
}
