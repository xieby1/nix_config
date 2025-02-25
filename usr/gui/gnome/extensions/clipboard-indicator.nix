#MC # clipboard-indicator: clipboard history
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.clipboard-indicator
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "clipboard-indicator@tudmotu.com"
      ];
    };
    "org/gnome/shell/extensions/clipboard-indicator" = {
      move-item-first=true;
    };
  };
}
