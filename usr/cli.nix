{ config, pkgs, stdenv, lib, ... }:
let
  isNixOnDroid = config.home.username == "nix-on-droid";
  git-wip = builtins.derivation {
    name = "git-wip";
    system = builtins.currentSystem;
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/bartman/git-wip/1c095e93539261370ae811ebf47b8d3fe9166869/git-wip";
      sha256 = "00gq5bwwhjy68ig26a62307pww2i81y3zcx9yqr8fa36fsqaw37h";
    };
    builder = pkgs.writeShellScript "git-wip-builder" ''
      source ${pkgs.stdenv}/setup
      mkdir -p $out/bin
      dst=$out/bin/git-wip
      cp $src $dst
      chmod +w $dst
      sed -i 's/#!\/bin\/bash/#!\/usr\/bin\/env bash/g' $dst
      chmod -w $dst
      chmod a+x $dst
    '';
  };
  fzf-doc = pkgs.writeScriptBin "fzf-doc" ''
    allCmds() {
      # bash alias
      compgen -A alias

      # external commands
      # https://unix.stackexchange.com/questions/94775/list-all-commands-that-a-shell-knows
      case "$PATH" in
        (*[!:]:) PATH="$PATH:" ;;
      esac
      set -f
      IFS_OLD="$IFS"
      IFS=:
      for dir in $PATH; do
        set +f
        [ -z "$dir" ] && dir="."
        for file in "$dir"/*; do
          if [ -x "$file" ] && ! [ -d "$file" ]; then
            echo "''${file##*/}"
          fi
        done
      done
      IFS="$IFS_OLD"
    }

    cd ~/Documents
    FILE=$(fzf)
    [ -z "$FILE" ] && exit

    CMD=$(allCmds | fzf)
    [ -z "$CMD" ] && exit

    case "$CMD" in
    # run gui cmd background
    o)
      # use nohup to run bash command in background and exit
      ## https://superuser.com/questions/448445/run-bash-script-in-background-and-exit-terminal
      # nohup not recognize bash alias like `o`, it's necessary to call bash
      eval nohup bash -ic '"$CMD \"$FILE\" &"'
    ;;

    # run cli cmd foreground
    *)
      # FILE name may contain space, quote FILE name
      eval "$CMD" \"$FILE\"
    ;;
    esac
  '';
  sysconfig = (
    if (builtins.tryEval <nixos-config>).success
    then import <nixpkgs/nixos> {}
    else import <nixpkgs/nixos> {configuration={};}
  ).config;
  my-capstone = pkgs.capstone.overrideAttrs (old: {
    version = "next-5.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "capstone-engine";
      repo = "capstone";
      rev = "6eb1db9c04113ac0a05f2dfd228704c84775530f";
      hash = "sha256-ejshOt02jaAJkuyS8T+T6v3Td4Jqg19zKgVMZ5VuISs=";
    };
  });
in
{
  imports = [ # files
    ./cli/vim.nix
    ./cli/tcl.nix
    ./cli/clash.nix
    ./cli/tailscale.nix
  ] ++ [{ # functions & attrs
    home.packages = [
      pkgs.fzf
      fzf-doc
    ];
    programs.bash.bashrcExtra = ''
      # FZF top-down display
      export FZF_DEFAULT_OPTS="--reverse"
    '';
  }{
    home.packages = lib.optional (!isNixOnDroid) pkgs.hstr;
    programs.bash.bashrcExtra = lib.optionalString (!isNixOnDroid) ''
      # HSTR configuration - add this to ~/.bashrc
      alias hh=hstr                    # hh to be alias for hstr
      export HSTR_CONFIG=hicolor       # get more colors
      shopt -s histappend              # append new history items to .bash_history
      export HISTCONTROL=ignorespace   # leading space hides commands from history
      # ensure synchronization between bash memory and history file
      export PROMPT_COMMAND="history -a;"
      # if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
      if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi
      # if this is interactive shell, then bind 'kill last command' to Ctrl-x k
      if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi
    '';
  }{
    programs.ssh.enable = true;
    programs.ssh.extraConfig =
      if builtins.pathExists ~/Gist/Config/ssh.conf
      then
        builtins.readFile ~/Gist/Config/ssh.conf
      else
        "";
    programs.bash.bashrcExtra = lib.optionalString isNixOnDroid ''
      # start sshd
      if [[ -z "$(ps|grep sshd-start|grep -v grep)" ]]; then
          sshd-start &> /dev/null &
      fi
    '';
  }{
    home.packages = with pkgs; [
      gitui
      mr
      git-wip
    ];
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userEmail = "xieby1@outlook.com";
      userName = "xieby1";
      extraConfig = {
        core = {
          editor = "vim";
        };
      };
      aliases = {
        viz = "log --all --decorate --oneline --graph";
      };
    };
    home.file.mr = {
      text = if builtins.pathExists ~/Gist/Config/mrconfig
        then builtins.readFile ~/Gist/Config/mrconfig
        else "";
      target = ".mrconfig";
    };
    # mr status not work in non-home dir
    programs.bash.shellAliases.mr = "mr -d ~";
  }{
    home.packages = [pkgs.nix-index];
    home.file.nix_index_database = {
      source = builtins.fetchurl "https://github.com/Mic92/nix-index-database/releases/latest/download/index-${builtins.currentSystem}";
      target = ".cache/nix-index/files";
    };
  }{
    home.packages = [pkgs.tmux];
    home.file.tmux = {
      text = ''
        # display status at top
        set -g status-position top
        set -g status-right ""

        # status bar
        ## display title on terminal
        set -g set-titles on
        set -g window-status-format "#I #W #{=/-20/…:pane_title}"
        set -g window-status-current-format "🐶#I #W #{=/-20/…:pane_title}"
        ## hide status bar when only one window
        ### refer to
        ### https://www.reddit.com/r/tmux/comments/6lwb07/is_it_possible_to_hide_the_status_bar_in_only_a/
        ### It not good, since its global!
        # if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
        # set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
        # set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
        ## color
        ### colour256的前10个和终端(gnome-terminal tango)的配色一致
        set -g status-style "bg=white fg=black"
        set -g window-status-last-style "bg=white fg=green bold"
        set -g window-status-current-style "bg=black fg=green bold"
        # set -g window-status-separator "|"

        # enable mouse scroll
        set -g mouse on

        # window index start from 1
        set -g base-index 1
        setw -g pane-base-index 1

        # auto re-number
        set -g renumber-windows on

        # Set new panes to open in current directory
        bind c new-window -c "#{pane_current_path}"
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # alt-num select window
        bind-key -n M-1 select-window -t 1
        bind-key -n M-2 select-window -t 2
        bind-key -n M-3 select-window -t 3
        bind-key -n M-4 select-window -t 4
        bind-key -n M-5 select-window -t 5
        bind-key -n M-6 select-window -t 6
        bind-key -n M-7 select-window -t 7
        bind-key -n M-8 select-window -t 8
        bind-key -n M-9 select-window -t 9
        # ctrl-t new window
        bind-key -n C-t new-window -c "#{pane_current_path}"

        # vi key bindings
        set -g mode-keys vi
        set -g status-keys vi
      '';
      target = ".tmux.conf";
    };
  }];

  home.packages = with pkgs; [
    # tools
    parallel
    comma
    xclip
    ## archive
    unar
    ## manage
    htop
    nix-tree
    ## text
    pandoc
    mdbook
    pdftk
    ## compile
    gnumake
    makefile2graph
    remake
    ## draw
    graphviz
    gnuclad
    imagemagick
    figlet
    ## manual
    tldr
    ## file system
    file
    ranger
    ## network
    frp
    wget
    lsof
    bind.dnsutils # nslookup
    netcat
    nload
    nmap
    ## x11
    xdotool

    # programming
    universal-ctags
    cscope
    clang-tools
    cmake
    my-capstone
    scc
    sloccount
    linuxPackages.perf
    flamegraph
    ## python
    ( python3.withPackages ( p: with p; [
      ipython
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
    gdb
    cling # c/cpp repl
    ### docs
    stdmanpages
    man-pages
    #gccStdenv
    bear
    ## xml
    libxml2
    ## bash
    bc
    ## javascript
    nodePackages.typescript
    ### node
    nodejs
    nodePackages.node2nix
    ## java
    openjdk
    ## nix
    rnix-lsp
    nixos-option
    ### allow non-nixos access `man configuration.nix`
    sysconfig.system.build.manual.manpages
    # runXonY
    debootstrap
    qemu
  ];

  programs.exa.enable = true;
  programs.exa.enableAliases = true;

  # bash
  programs.bash.enable = true;
  programs.bash.shellAliases.o = "xdg-open";
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
    PS1+="''${u_green}\u${lib.optionalString (!isNixOnDroid) "@\\h"}''${u_white}:"
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
  '' + lib.optionalString isNixOnDroid ''
    # alias all script
    ## due to cannot exec script under symlink directory (Gist)
    for SH in ~/Gist/script/bash/*; do
        eval "alias ''${SH##*/}='bash $SH'"
    done
  '';

  home.file.gdbinit = {
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/2b107b27949d13f6ef041de6eec1ad2e5f7b4cbf/.gdbinit";
      sha256 = "02rxyk8hmk7xk1pyhnc5z6a2kqyd63703rymy9rfmypn6057i4sr";
      name = "gdbinit";
    };
    target = ".gdbinit";
  };
  home.file.gdb_dashboard_init = {
    text = ''
      # gdb-dashboard init file

      # available layout modules
      #   stack registers history assembly
      #   breakpoints expressions memory
      #   source threads variables
      dashboard -layout source

      # https://en.wikipedia.org/wiki/ANSI_escape_code
      #dashboard -style prompt
      ## fg bold blue
      dashboard -style prompt_not_running "\\[\\e[1;34m\\]$\\[\\e[0m\\]"
      ## fg bold green
      dashboard -style prompt_running "\\[\\e[1;32m\\]$\\[\\e[0m\\]"
    '';
    target = ".gdbinit.d/init";
  };

  home.file.ranger_conf = {
    text = ''
      set preview_images_method kitty
    '';
    target = ".config/ranger/rc.conf";
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.syncthing = {
    enable = true;
    extraOptions = lib.optional config.isCli "--gui-address=0.0.0.0:8384";
  };
  systemd.user.services.syncthing.Service.Environment = [
    # https://docs.syncthing.net/users/proxying.html
    "http_proxy=http://127.0.0.1:${toString config.proxyPort}"
  ];
}
