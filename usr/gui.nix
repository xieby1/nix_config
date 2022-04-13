{ config, pkgs, stdenv, lib, ... }:
{
  imports = [
    ./gui/gnome.nix
    ./gui/mime.nix
  ];

  home.packages = with pkgs; [
    # browser
    google-chrome
    # network
    qv2ray
    kdeconnect
    # text
    #wpsoffice
    libreoffice
    obsidian
    texmaker
    meld
    # draw
    drawio
    aseprite-unfree
    # viewer
    xdot
    # management
    zotero
    # entertainment
    mgba
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

  home.file.v2ray_core = {
    source = pkgs.fetchzip {
      url = "https://github.com/v2fly/v2ray-core/releases/download/v4.44.0/v2ray-linux-64.zip";
      sha256 = "dn7AZzkvUNDYVyZv4MZGwE+lDesm3fc0ul+64K41bTE=";
      stripRoot = false;
    };
    target = ".config/qv2ray/vcore";
  };
  systemd.user.services.qv2ray = {
    Unit = {
      Description = "Auto start qv2ray";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.qv2ray.outPath}/bin/qv2ray";
    };
  };

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
}
