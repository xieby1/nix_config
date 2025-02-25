{ pkgs, ... }: {
  imports = [
    ./bing-wallpaper-changer.nix
    ./clipboard-indicator.nix
    ./customize-ibus.nix
    ./dash-to-dock.nix
    ./gtile.nix
    ./hide-top-bar.nix
    ./system-monitor.nix
    ./transparent-top-bar.nix
    ./unite.nix
  ];
  home.packages = with pkgs.gnomeExtensions; [
    always-show-titles-in-overview
    x11-gestures
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      ## enabled gnome extensions
      disable-user-extensions = false;
      disabled-extensions = [];
      enabled-extensions = [
        "Always-Show-Titles-In-Overview@gmail.com"
        "x11gestures@joseexposito.github.io"
      ];
    };
  };
}
