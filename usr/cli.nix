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
    hugo
    ## compile
    gnumake
    makefile2graph
    ## draw
    graphviz
    ## manual
    tldr
    ## file system
    tree
    ## network
    frp

    # programming
    ## python
    python3
    ## c
    gcc
    #gccStdenv
    bear
    ## xml
    libxml2
    ## latex
    texlive.combined.scheme-full # HUGE SIZE!

    # chroot
    debootstrap
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
      http.proxy = "http://127.0.0.1:8889";
    };
  };

  # mr
  home.file.mr =
    if builtins.pathExists ~/Gist/Config/mrconfig
    then
    {
      source = ~/Gist/Config/mrconfig;
      target = ".mrconfig";
    }
    else
    {
      text = "";
      target = ".mrconfig";
    };

  # bash
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    view = "nvim -R";
    mr = "mr -d ~"; # mr status not work in non-home dir
  };
  programs.bash.bashrcExtra =
    if builtins.pathExists ~/Gist/Config/bashrc
    then
      builtins.readFile ~/Gist/Config/bashrc
    else
      "";
}
