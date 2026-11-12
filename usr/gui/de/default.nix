{ pkgs, lib, ... }:
let
  sources = import <npins> {input = ./sources.json;};
  depkgs = import sources.nixpkgs {};
in {
  imports = [
    (lib.modules.importApply ./niri { inherit depkgs; })
    # ./dms
    (lib.modules.importApply ./noctalia { inherit depkgs; })
  ];
  home.packages = [
    pkgs.adwaita-icon-theme
    pkgs.papirus-icon-theme
  ];
}
