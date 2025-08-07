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
      intellihide-mode="ALL_WINDOWS";
      running-indicator-style="DOTS";
      click-action="focus-or-appspread";
      transparency-mode = "FIXED";
      background-opacity = 0.4;
      shortcut=["<Shift><Super>h"];
      shortcut-text="<Super><Shift>h";
      scroll-action="cycle-windows";
      shift-click-action="launch";
      middle-click-action="previews";
      # shift-middle-click-action="launch";
    };
  };
}
