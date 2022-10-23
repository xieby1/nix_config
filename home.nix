{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./usr/cli.nix
  ] ++ (if (builtins.getEnv "DISPLAY")!=""
  then [
    ./usr/gui.nix
  ] else []);

  programs.home-manager.enable = true;
}
