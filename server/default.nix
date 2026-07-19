{ lib, ... }:
{
  imports = [
    ./authelia
    ./caddy
    ./sixu.nix

    ../usr/cli/basic

    # TODO: group ../usr/*
    ../usr/modules

    # TODO group following to ../usr/cli/sh
    ../usr/cli/zsh

    ../usr/cli/git.nix

    ../usr/cli/clash

    # TODO: clean!
    ../usr/cli/vim

    ../usr/cli/tailscale

    # See ./home-manager-pi-ssh-stall.md
    ../usr/cli/ai/agents/pi

    ../usr/cli/ssh.nix
  ];

  options.my.server.caddyAuthelia.enable = lib.mkEnableOption "Caddy + Authelia prototype user services";

  config = {
    targets.genericLinux.enable = true;
    targets.genericLinux.gpu.enable = false;

    my.server.caddyAuthelia.enable = true;

    # TODO: deduplcate, as this snippet is also in user/default.nix
    programs.zsh.initContent = ''
      . ${toString ../scripts/bootstrap/main.sh}
    '';
    # envExtra gives non-interactive zsh, such as ssh 'cmd', the existing pin paths.
    # initContent runs the heavier bootstrap repair only for interactive shells.
    programs.zsh.envExtra = /*bash*/ ''
      if [[ -e "$HOME/.config/npins/nixpkgs" && -e "$HOME/.config/npins/home-manager" ]]; then
        export NIX_PATH="nixpkgs=$HOME/.config/npins/nixpkgs:home-manager=$HOME/.config/npins/home-manager:nixos-config=/etc/nixos/configuration.nix"
      fi
    '';

    # TODO: deduplcate
    services.syncthing.enable = true;

  };
}
