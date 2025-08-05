#MC # dash-to-dock
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.dash-to-dock
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
      ];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      running-indicator-style="DOTS";
      click-action="focus-or-appspread";
      transparency-mode = "FIXED";
      background-opacity = 0.4;
      shortcut= [];
    };
  };
}
