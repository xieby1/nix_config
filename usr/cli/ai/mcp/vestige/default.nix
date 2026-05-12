{ ... }: let
  vestige = import ./package.nix;
in {
  home.packages = [vestige];
  cachix_packages = [vestige];
}
