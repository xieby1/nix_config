{ pkgs, ... }: {
  imports = [
    ./settings.nix
    ./plugins
    ./clsettings.nix
  ];
  home.packages = [
    pkgs.dms-shell
    pkgs.quickshell
    pkgs.dgop

    # App icons for many apps not showing in App Launcher.
    # https://github.com/AvengeMedia/DankMaterialShell/issues/1132
    pkgs.papirus-icon-theme
    pkgs.adwaita-icon-theme
  ];
}
