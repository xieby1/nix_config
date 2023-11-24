#MC # home.nix
#MC
#MC This file is the entry point of home-manager's config.
#MC It imports my global options in `./opt.nix`,
#MC my CLI configs in `./usr/cli.nix`
#MC and my GUI configs in `./usr/gui.nix`.
#MC The environment variable `DISPLAY` is used to determine whether to enable the GUI configs.
{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./opt.nix
    ./usr/cli.nix
    # Q: how to use isGui here?
    # A: Not possible.
    #    As isGui is evaluated after `imports` being evaluated,
    #    use config.isGui here cause infinite loop.
  ] ++ lib.optionals ((builtins.getEnv "DISPLAY")!="") [
    ./usr/gui.nix
  ];

  home.stateVersion = "18.09";
  programs.home-manager.enable = true;
}
