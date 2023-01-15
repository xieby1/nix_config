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
  mytypora = (pkgs.callPackage (pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/137f19d1d48b6d7c7901bb86729a2bce3588d4e9/pkgs/applications/editors/typora/default.nix";
    sha256 = "057dk4hl4fljn50098g7l35sh7gwm7zqqqlrczv5lhmpgxi971c1";
  }) {}).overrideAttrs (old: {
    src = pkgs.fetchurl {
      url = "https://web.archive.org/web/20211222112532/https://download.typora.io/linux/typora_0.9.98_amd64.deb";
      sha256 = "1srj1fdcblfdsfvdnrqnwsxd3y8qd1h45p4sf1mxn6hr7z2s6ai6";
    };
  });
in
{
  imports = [
    ./gui/gnome.nix
    ./gui/mime.nix
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
    obsidian
    mytypora
    # logseq
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
    imhex
    xelfviewer
    vlc
    xournalpp # pdf annotation
    # management
    zotero
    barrier
    # entertainment
    mgba
    dgen-sdl # sega md emulator
    ## icon miss?
    #(retroarch.override {
    #  cores = with libretro; [
    #    libretro.beetle-gba
    #  ];
    #})
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
