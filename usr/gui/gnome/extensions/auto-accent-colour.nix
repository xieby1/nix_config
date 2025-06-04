{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.auto-accent-colour
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "auto-accent-colour@Wartybix"
      ];
    };
    "org/gnome/shell/extensions/auto-accent-colour" = {
      hide-indicator = true;
    };
  };
}
