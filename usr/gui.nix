{ config, pkgs, stdenv, lib, ... }:
let
  feishu = pkgs.callPackage ./gui/feishu.nix {};
  imhex = pkgs.callPackage ./gui/imhex.nix {};
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
      pkgs.xdot
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
  ];

  home.packages = with pkgs; [
    # browser
    google-chrome
    firefox
    # network
    mykdeconnect
    feishu
    # nur.repos.xddxdd.wechat-uos-bin
    # (nur.repos.xddxdd.wine-wechat.override {
    #   sha256 = "sha256-E0ZGFVp9h42G3iMzJ26P7WiASSgRdgnTHUTSRouFQYw=";
    # })
    (import ./gui/weixin.nix {})
    nur.repos.linyinfeng.wemeet
    transmission-gtk
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

  programs.qutebrowser = {
    enable = true;
    # https://qutebrowser.org/doc/help/settings.html
    settings = {
      qt.highdpi = true;
      new_instance_open_target = "window";
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
