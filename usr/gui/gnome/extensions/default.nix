#MC # Gnome Extensions
#MC
#MC Each time home-manager switched, no need log out.
#MC Just reload extension by <alt>+F2 r
{ pkgs, ... }: {
  imports = [
    ./advanced-alttab-window-switcher.nix
    ./bing-wallpaper-changer.nix
    ./bluetooth-battery-meter.nix
    ./dash-to-dock.nix
    ./gtile.nix
    ./hide-top-bar.nix
    ./pano.nix
    ./system-monitor.nix
    ./transparent-top-bar.nix
    ./unite.nix
    ./lunar-calendar.nix
    ./auto-accent-colour.nix
  ];
  home.packages = with pkgs.gnomeExtensions; [
    always-show-titles-in-overview
    x11-gestures
  ] ++ [
    pkgs.gnome45Extensions."permanent-notifications@bonzini.gnu.org"
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
        "permanent-notifications@bonzini.gnu.org"
      ];
    };
  };
}
