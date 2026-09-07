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
  programs.ssh.settings = {
    "*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
    # https://docs.github.com/zh/authentication/troubleshooting-ssh/using-ssh-over-the-https-port
    "github.com" = {
      HostName = "ssh.github.com";
      Port = 443;
      User = "git";
      ProxyCommand = "nc -X connect -x 127.0.0.1:${toString config.proxyPort} %h %p";
    };
    "aliyun" = {
      HostName = lib.trim (builtins.readFile ~/Gist/Vault/server/ip.txt);
      User = "root";
      ServerAliveInterval = 60;
    };
  };
  programs.zsh.initContent = lib.optionalString config.isNixOnDroid ''
    # start sshd
    if [[ -z "$(pidof sshd-start)" ]]; then
        tmux new -d -s sshd-start sshd-start
    fi
  '';
}
