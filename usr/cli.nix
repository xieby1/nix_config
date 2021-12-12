{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./vim.nix
  ];

  home.packages = with pkgs; [
    # tools
    gitui
    mr
    unar
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

  # mr
  home.file.mr = {
    source = ./cfg/mrconfig;
    target = ".mrconfig";
  };

  # bash
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    view = "nvim -R";
    mr = "mr -d ~"; # mr status not work in non-home dir
  };
}
