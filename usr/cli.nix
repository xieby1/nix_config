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
    file
    fzf
    ## network
    frp
    wget

    # programming
    ## There is a bug in aarch64
    ## refers to https://github.com/NixOS/nixpkgs/pull/151904
    ## TODO: remove this compromise after fix being merged in nixpkgs
    (
      if builtins.currentSystem == "aarch64-linux"
      then
        universal-ctags.overrideAttrs (
          oldAttrs: rec {
            depsBuildBuild = [ pkgs.buildPackages.stdenv.cc ];
        })
      else
        universal-ctags
    )
    cscope
    clang-tools
    ## python
    python3
    ## c
    gcc
    ### docs
    stdmanpages
    man-pages
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
      # android uses global proxy
      # TODO: more specific, aarch64-linux may not be android
      http.proxy = if builtins.currentSystem == "aarch64-linux"
        then
          ""
        else
          "http://127.0.0.1:8889";
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
      # services.espanso.enable uses "default.target" which not work
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.espanso}/bin/espanso daemon";
    };
  };

  # tmux
  home.file.tmux =
    if builtins.pathExists ~/Gist/Config/tmux.conf
    then
    {
      source = ~/Gist/Config/tmux.conf;
      target = ".tmux.conf";
    }
    else
    {
      text = "";
      target = ".tmux.conf";
    };
}
