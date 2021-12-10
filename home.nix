{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./usr/cli.nix
    ./usr/gui.nix
  ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}
