{ depkgs }: # local args
{ pkgs, lib, ... }: let
  local = lib.modules.evalModules {
    modules = [(lib.modules.importApply ./local {inherit pkgs depkgs;})];
  };
in {
  cachix_packages = [ local.config.finalPackage ];
  home.file.niri_config = {
    text = local.config.finalConfigKdlText;
    target = ".config/niri/config.kdl";
  };

  home.packages = [
    local.config.finalPackage
    pkgs.xwayland-satellite
    pkgs.gcr # Provides org.gnome.keyring.SystemPrompter for unlocking the keyring.
  ];
  services.gnome-keyring.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    configPackages = [ local.config.finalPackage ];
  };
}
