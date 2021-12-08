{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./modules/cli.nix
    ./modules/gui.nix
  ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}
