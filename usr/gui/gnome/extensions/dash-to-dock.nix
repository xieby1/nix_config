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
      # DOTS support at most 4 windows counting,
      # BINARY supports at most 2^4-1 windows counting
      running-indicator-style="BINARY";
      custom-theme-customize-running-dots=true;
      custom-theme-running-dots-border-color="rgb(0,0,0)";
      custom-theme-running-dots-border-width="4";
      custom-theme-running-dots-color="rgb(255,255,255)";

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
