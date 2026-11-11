{ pkgs, lib, ... }: let
  local = lib.modules.evalModules {
    modules = [(lib.modules.importApply ./local {inherit pkgs; depkgs=pkgs;})];
  };
in {
  nixpkgs.overlays = [
    (pkgs-final: pkgs-prev: {
      niri = pkgs-prev.niri.overrideAttrs (niri-final: niri-prev: {
        patches = niri-prev.patches ++ [
          # https://github.com/niri-wm/niri/discussions/1380
          ./focus-shrink.patch
        ];
      });
    })
  ];
  cachix_packages = [ local.config.finalPackage ];
  home.file.niri_config = {
    text = local.config.finalConfigKdlText;
    target = ".config/niri/config.kdl";
  };

  home.packages = [
    local.config.finalPackage
    pkgs.xwayland-satellite
  ];
  services.gnome-keyring.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    configPackages = [ local.config.finalPackage ];
  };
}
