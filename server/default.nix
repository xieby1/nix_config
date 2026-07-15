{ lib, ... }:
{
  imports = [
    ./authelia
    ./caddy

    # TODO: group ../usr/*
    ../usr/modules

    # TODO group following to ../usr/cli/sh
    ../usr/cli/starship.nix
    ../usr/cli/zsh

    ../usr/cli/git.nix

    ../usr/cli/clash

    # TODO: clean!
    ../usr/cli/vim
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

    # TODO: deduplcate
    services.syncthing.enable = true;

  };
}
