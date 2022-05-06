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
    kdeconnect
    # text
    #wpsoffice
    libreoffice
    obsidian
    meld
    # draw
    drawio
    aseprite-unfree
    inkscape
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
}
