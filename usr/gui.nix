{ config, pkgs, stdenv, lib, ... }:
let
  feishu = pkgs.callPackage ./gui/feishu.nix {};
  mykdeconnect = pkgs.kdeconnect.overrideAttrs (old: {
    patches = [( pkgs.fetchpatch {
      url = "https://raw.githubusercontent.com/xieby1/kdeconnect-kde-enhanced/4610431b932b2fab05d7e0fc55e7306dc7ff0910/diff.patch";
      sha256 = "1d3ycpaaglr42bndajz1sxcavhm4p5k9n1rd5isjkim1w7ir8z56";
    })];
    # cmakeFlags = "-DCMAKE_BUILD_TYPE=Debug -DQT_FORCE_STDERR_LOGGING=1";
  });
in
{
  imports = [
    ./gui/gnome.nix
    ./gui/mime.nix
    ./gui/terminal.nix
  ];

  home.packages = with pkgs; [
    # browser
    google-chrome
    # network
    mykdeconnect
    feishu
    # text
    #wpsoffice
    libreoffice
    obsidian
    meld
    espanso
    # draw
    drawio
    #aseprite-unfree
    inkscape
    gimp
    # viewer
    xdot
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

  xdg.desktopEntries = {
    xdot = {
      name = "xdot";
      exec = "xdot %U";
    };
  };

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

  xdg.desktopEntries = {
    clash = {
      name = "clash";
      exec = "qutebrowser http://clash.razord.top";
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
