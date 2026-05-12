{ pkgs, ... }: let
  vestige = pkgs.callPackage ./package.nix {src = pkgs.npinsed.ai.vestige;};
in {
  home.packages = [vestige];
  cachix_packages = [vestige];
}
