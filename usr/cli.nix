{ config, pkgs, stdenv, lib, ... }:
let
  comma = import ( pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "comma";
    # master branch arm not work, wait for fixing, see:
    # https://github.com/nix-community/comma/issues/17
    rev = "54149dc417819af14ddc0d59216d4add5280ad14";
    sha256 = "1xjyn42w18w2mn16i7xl0dvay60w82ghayan1ia7v1qqr0a0fac9";
  }) {};
  nix-alien-pkgs = import ( pkgs.fetchFromGitHub {
    owner = "thiagokokada";
    repo = "nix-alien";
    # master needs to build python3, so pin to a stable version
    rev = "2820f11c5a3e0ccae4fa705cc9898084ec1f523c";
    sha256 = "141da8c4zqp52imwyffs0hnx1b71qfic8nah6djqdh154693fw7z";
  }) {};
in
{
  imports = [
    ./cli/vim.nix
  ];

  home.packages = with pkgs; [
    # tools
    parallel
    comma
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
    mdbook
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
    ## x11
    xdotool

    # programming
    cscope
    clang-tools
    ## python
    python3
    ## c
    gcc
    gdb
    cling # c/cpp repl
    ### docs
    stdmanpages
    man-pages
    #gccStdenv
    bear
    ## xml
    libxml2

    # runXonY
    debootstrap
    qemu
  ] ++ (if builtins.currentSystem == "x86_64-linux"
  then [
    nix-alien-pkgs.nix-alien
    nix-alien-pkgs.nix-index-update
  ] else []);

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
  programs.bash.bashrcExtra = builtins.readFile ./cli/bashrc;

  # espanso
  home.file.espanso = {
    source = ./cli/espanso.yml;
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
  home.file.tmux = {
    source = ./cli/tmux.conf;
    target = ".tmux.conf";
  };
}
