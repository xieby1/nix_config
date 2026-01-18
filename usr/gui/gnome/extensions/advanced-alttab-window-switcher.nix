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
      # do not show preview for selected window
      switcher-popup-preview-selected=1;
      # all workspaces
      win-switcher-popup-filter=1;
      win-switch-include-modals=true;

      enable-super=true;
      # super => window switcher
      super-key-mode=3;
      # show overview
      super-double-press-action=3;
      # Activate app after mouse out. But why needs this?
      # If not enable this, the app switcher will not exit automatically,
      # which may be a bug.
      switcher-popup-activate-on-hide=true;
    };
  };
}
