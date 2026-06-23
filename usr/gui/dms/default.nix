{ pkgs, ... }: {
  imports = [
    (let
      # TODO: Why does `pkgs` above not work?
      pkgs = import <nixpkgs> {};
      flake-dms = pkgs.flake-compat {
        src = pkgs.npinsed.de.DankMaterialShell;
      };
    in flake-dms.defaultNix.homeModules.dank-material-shell)
    ./settings.nix
    ./plugins
    ./clsettings.nix
  ];
  programs.dank-material-shell = {
    enable = true;
    # https://github.com/AvengeMedia/DankMaterialShell/issues/1489
    dgop.package = (pkgs.flake-compat {
      src = pkgs.npinsed.de.dgop;
    }).defaultNix.default;
  };
  home.packages = [
    # App icons for many apps not showing in App Launcher.
    # https://github.com/AvengeMedia/DankMaterialShell/issues/1132
    pkgs.papirus-icon-theme
    pkgs.adwaita-icon-theme
  ];
}
