{ config, pkgs, stdenv, lib, ... }:
let
  sysconfig = (
    # <...> are expression search in NIX_PATH
    if (builtins.tryEval <nixos-config>).success
    then import <nixpkgs/nixos> {}
    else import <nixpkgs/nixos> {configuration={};}
  ).config;
in
{
  imports = [
    ./extra.nix
    ./vim
    ./tmux.nix
    ./clash.nix
    ./tailscale.nix
    ./gdb.nix
    ./ctags.nix
    ./ssh.nix
    ./git.nix
    ./fzf.nix
    ./tldr.nix
    ./typst
  ] ++ [{ # functions & attrs
    home.packages = [pkgs.nix-index];
    home.file.nix_index_database = {
      source = builtins.fetchurl "https://github.com/Mic92/nix-index-database/releases/latest/download/index-${builtins.currentSystem}";
      target = ".cache/nix-index/files";
    };
  }{
    #MC ## Syncthing
    services.syncthing = {
      enable = true;
      #MC 让syncthing的端口外部可访问。
      extraOptions = lib.optional config.isCli "--gui-address=0.0.0.0:8384";
    };
    #MC 启用代理，因为有些syncthing的服务器似乎是被墙了的。
    systemd.user.services.syncthing.Service.Environment = [
      # https://docs.syncthing.net/users/proxying.html
      "http_proxy=http://127.0.0.1:${toString config.proxyPort}"
    ];
    #MC 使用命令行浏览器browsh来实现syncthing-tui。
    home.packages = lib.optional (!config.isMinimalConfig) (
      pkgs.writeShellScriptBin "syncthing-tui" ''
        ${pkgs.browsh}/bin/browsh --firefox.path ${pkgs.firefox}/bin/firefox http://127.0.0.1:8384
      ''
    );
  }{
    home.packages = with pkgs; [
      cachix
    ];
    home.file.cachix_dhall = {
      source = if (builtins.pathExists ~/Gist/Config/cachix.dhall)
        then ~/Gist/Config/cachix.dhall
        else builtins.toFile "empty-cachix.dhall" "";
      target = ".config/cachix/cachix.dhall";
    };
  }{
    home.packages = [
      pkgs.pkgsu.claude-code
    ];
    systemd.user.tmpfiles.rules = [
      "L? %h/.claude/settings.json - - - - %h/Gist/Config/claude.settings.json"
    ];
  }];

  home.packages = with pkgs; [
    # tools
    parallel
    comma
    xclip
    python3Packages.qrcode
    ## archive
    unar
    ## manage
    htop
    nix-tree
    ## text
    pandoc
    ## compile
    gnumake
    makefile2graph
    remake
    ## draw
    graphviz
    figlet
    nyancat
    d2
    ## file system
    file
    # magika # detect file content types with deep learning
    tree
    ## network
    wget
    axel
    bind.dnsutils # nslookup
    netcat
    nload
    nmap
    nethogs
    nodePackages.browser-sync
    ## x11
    xdotool

    # programming
    inotify-tools
    clang-tools
    cmake
    capstone
    scc
    ## https://stackoverflow.com/questions/40165650/how-to-list-all-files-tracked-by-git-excluding-submodules
    (writeShellScriptBin "scc-git" "${scc}/bin/scc $(git grep --cached -l '')")
    flamegraph
    ## python
    ( python3.withPackages ( p: with p; [
      ipython
      pydot
      networkx
    ]))
    ## c
    (lib.setPrio # make bintools less prior
      (bintools-unwrapped.meta.priority + 1)
      bintools-unwrapped
    )
    (if builtins.currentSystem == "x86_64-linux"
      then gcc_multi
      else gcc
    )
    ### docs
    stdmanpages
    man-pages
    #gccStdenv
    bear
    ## xml
    libxml2
    ## bash
    bc
    ## nix
    nixos-option
    nix-output-monitor
    ### allow non-nixos access `man configuration.nix`
    # see: nixos/modules/misc/documentation.nix
    #        nixos/doc/manual/default.nix
    sysconfig.system.build.manual.nixos-configuration-reference-manpage
    nurl
    pkgsu.npins
  ];

  programs.eza.enable = true;

  # bash
  programs.bash.enable = true;
  programs.bash.bashrcExtra = ''
    # rewrite prompt format
    u_green="\[\033[01;32m\]"
    u_blue="\[\033[01;34m\]"
    u_white="\[\033[00m\]"
    PS1="''${debian_chroot:+($debian_chroot)}"
    if [[ $HOSTNAME =~ qemu.* ]]; then
        PS1+="(qemu)"
    fi
    if [[ -n "$IN_NIX_SHELL" ]]; then
        PS1+="(''${name}.$IN_NIX_SHELL)"
    fi
    PS1+="''${u_green}\u${lib.optionalString (!config.isNixOnDroid) "@\\h"}''${u_white}:"
    PS1+="''${u_blue}\w''${u_white}"
    PS1+="\n''${u_green}\$''${u_white} "
    unset u_green u_blue u_white
    ## change title
    ### https://unix.stackexchange.com/questions/177572/
    PS1+="\[\e]2;\w\a\]"

    # nixos obsidian
    export NIXPKGS_ALLOW_INSECURE=1

    # source my bashrc
    if [[ -f ~/Gist/Config/bashrc ]]; then
        source ~/Gist/Config/bashrc
    fi

    # user nix config setting
    export NIX_USER_CONF_FILES=~/.config/nixpkgs/nix/nix.conf
    if [[ -e ~/.nix-profile/etc/profile.d/nix.sh ]]; then
        source ~/.nix-profile/etc/profile.d/nix.sh
    fi

    # bash-completion, inspired by
    ##  https://discourse.nixos.org/t/whats-the-nix-way-of-bash-completion-for-packages/20209/16
    # system tools completion, e.g. nix
    XDG_DATA_DIRS+=":${sysconfig.system.path}/share"
    # home tools completion
    XDG_DATA_DIRS+=":${config.home.path}/share"
    export XDG_DATA_DIRS
    . ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh

    # 解决tmux在nix-on-droid上不显示emoji和中文的问题
    export LANG=C.UTF-8

    if [[ -n $(command -v eza) ]]; then
        alias ls=eza
    fi
  '' + lib.optionalString config.isWSL2 ''
    # use the working directory of the current tab as the starting directory for a new tab
    # https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#using-actions-to-duplicate-the-path
    PROMPT_COMMAND=''${PROMPT_COMMAND:+"$PROMPT_COMMAND"}'printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"'
  '';

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--no-ignore-vcs"
    ];
  };

  programs.command-not-found.enable = true;
}
