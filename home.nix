{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./modules/cli_u.nix
    ./modules/gui_u.nix
  ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}
