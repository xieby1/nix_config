{ config, pkgs, stdenv, lib, ... }:
{
  home.packages = with pkgs; [
    # gnome extensions
    gnome40Extensions."BingWallpaper@ineffable-gmail.com"
    gnome40Extensions."clipboard-indicator@tudmotu.com"
    gnomeExtensions.dash-to-dock
    gnome40Extensions."gTile@vibou"
    gnome40Extensions."hidetopbar@mathieu.bidon.ca"
    ## not work
    gnomeExtensions.no-title-bar
    gnomeExtensions.system-monitor
    gnomeExtensions.vertical-overview

    # tools
    gitui
  ];

  programs.home-manager.enable = true;

  # gnome-terminal
  ## dconf dump /org/gnome/terminal/legacy/profiles:/
  programs.gnome-terminal.enable = true;
  programs.gnome-terminal.profile = {
    "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      visibleName = "xieby1";
      default = true;
      font = "Monospace 18";
      # Tango
      colors = {
        foregroundColor = "rgb(211,215,207)";
        backgroundColor = "rgb(46,52,54)";
        palette = [
          "rgb(465254)" "rgb(20400)" "rgb(781546)" "rgb(1961600)" "rgb(52101164)" "rgb(11780123)" "rgb(6152154)" "rgb(211215207)" "rgb(858783)" "rgb(2394141)" "rgb(13822652)" "rgb(25223379)" "rgb(114159207)" "rgb(173127168)" "rgb(52226226)" "rgb(238238236)"
        ];
      };
    };
  };

  # dconf
  dconf.settings = {
    "org/gnome" = {
      ## enabled gnome extensions
      enabled-extension = [
        "BingWallpaper@ineffable-gmail.com"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "gTile@vibou"
        "hidetopbar@mathieu.bidon.ca"
        "Resource_Monitor@Ory0n"
        "system-monitor@paradoxxx.zero.gmail.com"
        "vertical-overview@RensAlthuis.github.com"
      ];
    };
  };

  # git
  programs.git = {
    enable = true;
    userEmail = "xieby1@outlook.com";
    userName = "xieby1";
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };
}
