{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./cli/vim.nix
  ];

  home.packages = with pkgs; [
    # tools
    ## repo
    gitui
    mr
    ## archive
    unar
    ## manage
    htop
    ## text
    pandoc
    ## compile
    gnumake
    makefile2graph
    ## draw
    graphviz
    ## manual
    tldr
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
  programs.bash.bashrcExtra = builtins.readFile ./cfg/bashrc;
}
