{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./usr/cli.nix
  ] ++ (if (builtins.getEnv "DISPLAY")!=""
  then [
    ./usr/gui.nix
  ] else []);

  home.stateVersion = "18.09";
  programs.home-manager.enable = true;
}
