{ pkgs, ... }: let
  mihomo-tui = pkgs.callPackage ./package.nix {};
in {
  home.packages = [
    pkgs.mihomo
    mihomo-tui
  ];
  cachix_packages = [
    mihomo-tui
  ];
}
