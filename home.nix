{ config, pkgs, stdenv, lib, ... }: {
  imports = [
    ./usr
  ];

  home.stateVersion = "19.09";
  programs.home-manager.enable = true;
}
