{ config, pkgs, stdenv, lib, ... }:
let
  nix-alien-pkgs = import ( pkgs.fetchFromGitHub {
    owner = "thiagokokada";
    repo = "nix-alien";
    # master needs to build python3, so pin to a stable version
    rev = "faeda0a028eca556dec136631f2e905fd7a46bb7";
    sha256 = "0z2p9jj4h2a688vw5g0zqy0380qj3xb9zmxq9wyisrx86hnnsaq0";
  }) {
    inherit pkgs;
    inherit (pkgs) poetry2nix;
  };
in
{
  imports = [
    ./cli/vim.nix
  ];

  home.packages = with pkgs; [
    # tools
    parallel
    comma
    nix-index
    xclip
    ## repo
    gitui
    mr
    ## archive
    unar
    ## manage
    htop
    tmux
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
    tree
    file
    fzf
    ranger
    ## network
    frp
    wget
    clash
    lsof
    bind.dnsutils # nslookup
    tailscale
    netcat
    nload
    ## x11
    xdotool

    # programming
    universal-ctags
    cscope
    clang-tools
    cmake
    capstone
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
  ] ++ (if builtins.currentSystem == "x86_64-linux"
      then [hstr] else []
  ) ++ [
    ## javascript
    nodePackages.typescript
    ### node
    nodejs
    nodePackages.node2nix
    ## java
    openjdk
    ## nix
    rnix-lsp

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
    package = pkgs.gitFull;
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

  # tmux
  home.file.tmux = {
    source = ./cli/tmux.conf;
    target = ".tmux.conf";
  };

  programs.ssh.enable = true;
  programs.ssh.extraConfig =
    if builtins.pathExists ~/Gist/Config/ssh.conf
    then
      builtins.readFile ~/Gist/Config/ssh.conf
    else
      "";

  systemd.user.services.clash = {
    Unit = {
      Description = "Auto start clash";
      After = ["network.target"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${pkgs.clash.outPath}/bin/clash -d ${config.home.homeDirectory}/Gist/clash";
    };
  };

  home.file.gdbinit = {
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/2b107b27949d13f6ef041de6eec1ad2e5f7b4cbf/.gdbinit";
      sha256 = "02rxyk8hmk7xk1pyhnc5z6a2kqyd63703rymy9rfmypn6057i4sr";
      name = "gdbinit";
    };
    target = ".gdbinit";
  };
  home.file.gdb_dashboard_init = {
    source = ./cli/gdbinit;
    target = ".gdbinit.d/init";
  };

  home.file.nix_index_database = {
    source = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-06-05/index-x86_64-linux";
      sha256 = "0zz47as14lsj930jm9gplsngxr5d92fsg7fw1qxk0lgq7phawj5m";
    };
    target = ".cache/nix-index/files";
  };

  home.file.ranger_conf = {
    source = ./cli/ranger.conf;
    target = ".config/ranger/rc.conf";
  };

  # for my headtail
  systemd.user.services.tailscaled-headscale = let
    stateDir = "${config.home.homeDirectory}/.local/share/tailscale-headscale";
  in {
    Unit = {
      Description = "Auto start tailscaled-headscale userspace network";
      After = ["clash.service"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Environment = [
        "HTTPS_PROXY=http://127.0.0.1:8889"
        "HTTP_PROXY=http://127.0.0.1:8889"
        "https_proxy=http://127.0.0.1:8889"
        "http_proxy=http://127.0.0.1:8889"
        "TS_LOGS_DIR=${stateDir}"
      ];
      ExecStart = builtins.toString [
        "${pkgs.tailscale}/bin/tailscaled"
        "--tun userspace-networking"
        "--outbound-http-proxy-listen=localhost:1055"
        "--socket=/tmp/tailscale-headscale.sock"
        "--state=${stateDir}/tailscaled.state"
        "--statedir=${stateDir}"
      ];
    };
  };

  # systemd.user.services.onedrive = {
  #   Unit = {
  #     Description = "OneDrive Free Client";
  #     Documentation = "https://github.com/abraunegg/onedrive";
  #     After = "network-online.target";
  #     Wants = "network-online.target";
  #   };
  #   Service = {
  #     Environment = ["HTTP_PROXY=http://127.0.0.1:8889" "HTTPS_PROXY=http://127.0.0.1:8889"];
  #     ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
  #     Restart = "on-failure";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };
  # home.file.onedrive = {
  #   source = ./cli/onedrive.config;
  #   target = ".config/onedrive/config";
  # };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.syncthing = let
    isCli = (builtins.getEnv "DISPLAY")=="";
  in {
    enable = true;
    extraOptions = if isCli
      then ["--gui-address=0.0.0.0:8384"]
      else [];
  };
}
