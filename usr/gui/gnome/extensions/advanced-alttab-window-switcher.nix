#MC # advanced-alttab-window-switcher
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.advanced-alttab-window-switcher
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "advanced-alt-tab@G-dH.github.com"
      ];
    };
    "org/gnome/shell/extensions/advanced-alt-tab-window-switcher" = {
      switcher-popup-preview-selected=2;
      win-switcher-popup-filter=2;
    };
  };
}
