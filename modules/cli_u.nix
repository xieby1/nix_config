{ config, pkgs, stdenv, lib, ... }:

{
  #imports = [
  #  ./vim.nix
  #];

  home.packages = with pkgs; [
    # tools
    gitui
    unar
    vim_configurable
  ];

  # git
  programs.git = {
    enable = true;
    userEmail = "xieby1@outlook.com";
    userName = "xieby1";
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };
}
