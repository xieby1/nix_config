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
    ./new-workspace-shortcut.nix
    ./wsp-windows-search-provider.nix
  ];
  home.packages = with pkgs.gnomeExtensions; [
    always-show-titles-in-overview
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
        "permanent-notifications@bonzini.gnu.org"
      ];
    };
  };
}
