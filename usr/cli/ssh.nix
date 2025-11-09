{ config, lib, pkgs, ... }: {
  home.packages = [
    pkgs.sshfs
  ];
  programs.ssh.enable = true;
  programs.ssh.includes = lib.optional (builtins.pathExists ~/Gist/Config/ssh.conf) "~/Gist/Config/ssh.conf";
  programs.bash.bashrcExtra = lib.optionalString config.isNixOnDroid ''
    # start sshd
    if [[ -z "$(pidof sshd-start)" ]]; then
        tmux new -d -s sshd-start sshd-start
    fi
  '';
}
