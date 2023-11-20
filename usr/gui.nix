{ config, pkgs, stdenv, lib, ... }:
let
  xelfviewer = pkgs.callPackage ./gui/xelfviewer.nix {};
  mykdeconnect = pkgs.kdeconnect;
  #mykdeconnect = pkgs.kdeconnect.overrideAttrs (old: {
  #  patches = [( pkgs.fetchpatch {
  #    url = "https://raw.githubusercontent.com/xieby1/kdeconnect-kde-enhanced/4610431b932b2fab05d7e0fc55e7306dc7ff0910/diff.patch";
  #    hash = "sha256-NL/TVOMEhdJ/W7UTxjF7Qjnq7JciNvl08BC1wrBfvHo=";
  #  })];
  #  # cmakeFlags = "-DCMAKE_BUILD_TYPE=Debug -DQT_FORCE_STDERR_LOGGING=1";
  #});
  myxdot = pkgs.symlinkJoin {
    name = "myxdot";
    paths = [
      # TODO: xdot gobject-introspection dependency broken
      #   refers to https://github.com/NixOS/nixpkgs/pull/206186
      (pkgs.xdot.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.gobject-introspection];
      }))
      (pkgs.makeDesktopItem {
        name = "xdot";
        desktopName = "xdot";
        exec = "xdot %U";
  })];};
  my-xournalpp = pkgs.xournalpp.overrideAttrs (old: {
    version = "nightly";
    src = pkgs.fetchFromGitHub {
      owner = "xournalpp";
      repo = "xournalpp";
      rev = "1dbb041f7b29d0175c943443747cbcf7953e3586";
      hash = "sha256-yeovSxdWCEvzxRZ3u40gEWZpIOoBsK9G4x17FK0C+PA=";
    };
    buildInputs = old.buildInputs ++ [pkgs.alsa-lib];
  });
  my-imhex = pkgs.callPackage ./gui/imhex.nix {};
in
{
  imports = [
    ./gui/mime.nix
  ] ++lib.optionals ((builtins.getEnv "WSL_DISTRO_NAME")=="") [
    ./gui/gnome.nix
    ./gui/terminal.nix
    ./gui/singleton_web_apps.nix
    ./gui/rofi.nix
  ];

  home.packages = with pkgs; [
    libnotify
    # browser
    google-chrome
    firefox
    # network
    mykdeconnect
    feishu
    nur.repos.xddxdd.wechat-uos
    # wine weixin waste too much memory, more than 4GB!!!
    #(import ./gui/weixin.nix {})
    nur.repos.linyinfeng.wemeet
    transmission-gtk
    tdesktop
    # text
    #wpsoffice
    libreoffice
    meld
    # TODO: use this after switching to wayland
    #wl-clipboard
    # draw
    drawio
    #aseprite-unfree
    inkscape
    gimp
    # viewer
    myxdot
    my-imhex
    xelfviewer
    vlc
    # my-xournalpp # pdf annotation
    xournalpp
    ghidra
    # management
    zotero
    barrier
    # entertainment
    antimicrox
    # music
    spotify
    # runXonY
    wineWowPackages.stable
    winetricks
  ];

  xdg.mime.types = {
    dot = {
      name = "graphviz-dot";
      type = "text/graphviz-dot";
      pattern = "*.dot";
      defaultApp = "xdot.desktop";
    };
    drawio = {
      name = "draw-io";
      type = "text/draw-io";
      pattern = "*.drawio";
      defaultApp = "drawio.desktop";
    };
  };

  home.file.kde_connect_indicator = {
    source = "${mykdeconnect}/share/applications/org.kde.kdeconnect.nonplasma.desktop";
    target = ".config/autostart/org.kde.kdeconnect.nonplasma.desktop";
  };
  home.file.autostart_barrier = {
    source = "${pkgs.barrier}/share/applications/barrier.desktop";
    target = ".config/autostart/barrier.desktop";
  };
}
