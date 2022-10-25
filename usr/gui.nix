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
        name = "myxdot";
        desktopName = "xdot";
        exec = "xdot %U";
  })];};
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
    (import ./gui/weixin.nix)
    # text
    #wpsoffice
    libreoffice
    obsidian
    logseq
    meld
    espanso
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

  # espanso
  home.file.espanso = {
    source = ./gui/espanso.yml;
    target = ".config/espanso/default.yml";
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
}
