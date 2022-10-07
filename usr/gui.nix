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

  xdg.desktopEntries = {
    xdot = {
      name = "xdot";
      exec = "xdot %U";
    };

    # web apps
    ## microsoft's
    todo = {
      name = "Microsoft To Do";
      genericName = "ToDo";
      exec = "/home/xieby1/Gist/script/bash/quteapp.sh \"To Do\" https://to-do.live.com/";
      icon = (pkgs.fetchurl {
        url = "https://todo.microsoft.com/favicon.ico";
        sha256 = "1742330y3fr79aw90bysgx9xcfx833n8jqx86vgbcp21iqqxn0z8";
      }).outPath;
    };
    calendar = {
      name = "Microsoft Calendar";
      exec = "/home/xieby1/Gist/script/bash/quteapp.sh Outlook https://outlook.live.com/calendar";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/o/82/outlook.svg";
        sha256 = "0544z9vmghp4lgapl00n99vksm0gq8dfwrp7rvfpp44njnh6b6dz";
      }).outPath;
    };
    outlook = {
      name = "Microsoft Outlook";
      exec = "/home/xieby1/Gist/script/bash/quteapp.sh Outlook https://outlook.live.com";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/o/82/outlook.svg";
        sha256 = "0544z9vmghp4lgapl00n99vksm0gq8dfwrp7rvfpp44njnh6b6dz";
      }).outPath;
    };
    onedrive = {
      name = "OneDrive";
      exec = "/home/xieby1/Gist/script/bash/quteapp.sh OneDrive https://onedrive.live.com";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/m/73/microsoft-onedrive.svg";
        sha256 = "10sjz81xjcqfkd7v11vhpvdp0s2a8la9wipc3aapgybg822vhjck";
      }).outPath;
    };
    ## others
    suishouji = {
      name = "随手记";
      genericName = "suishouji";
      exec = "/home/xieby1/Gist/script/bash/quteapp.sh 随手记 https://www.sui.com/";
      icon = (pkgs.fetchurl {
        url = "https://res.sui.com/favicon.ico";
        sha256 = "01vm275n169r0ly8ywgq0shgk8lrzg79d1aarshwybwxwffj4q0q";
      }).outPath;
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
