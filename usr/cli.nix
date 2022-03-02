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
    tmux
    ## text
    pandoc
    hugo
    espanso
    ## compile
    gnumake
    makefile2graph
    ## draw
    graphviz
    gnuclad
    ## manual
    tldr
    ## file system
    tree
    ## network
    frp

    # programming
    universal-ctags
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

    # runXonY
    debootstrap
    qemu_kvm
    #qemu-utils
    ## docker
    skopeo
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

  # espanso
  home.file.espanso =
    if builtins.pathExists ~/Gist/Config/espanso.yml
    then
    {
      source = ~/Gist/Config/espanso.yml;
      target = ".config/espanso/user/espanso.yml";
    }
    else
    {
      text = "";
      target = ".config/espanso/user/espanso.yml";
    };

  systemd.user.services.espanso = {
    Unit = {
      Description = "Espanso daemon";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.espanso}/bin/espanso daemon";
    };
  };
}
