{ depkgs }: # local args
{ pkgs, lib, ... }: let
  local = lib.modules.evalModules {
    modules = [(lib.modules.importApply ./local {inherit pkgs depkgs;})];
  };
in {
  wayland.windowManager.niri = {
    enable = true;
    package = local.config.finalPackage;
    extraConfig = local.config.finalConfigKdlText;
  };
  cachix_packages = [ local.config.finalPackage ];
  services.gnome-keyring.enable = true;
}
