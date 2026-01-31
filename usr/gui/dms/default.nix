# TODO: Why does this `pkgs` not work?
# { pkgs, ... }: {
{ config, ... }: let
  pkgs = import <nixpkgs> {};
in {
  imports = [
    (let
      flake-dms = pkgs.flake-compat {
        src = pkgs.fetchFromGitHub {
          owner = "AvengeMedia";
          repo = "DankMaterialShell";
          rev = "v1.2.3";
          hash = "sha256-P//moH3z9r4PXirTzXVsccQINsK5AIlF9RWOBwK3vLc=";
        };
      };
    in flake-dms.defaultNix.homeModules.dank-material-shell)
  ];
  programs.dank-material-shell = {
    enable = true;
    # https://github.com/AvengeMedia/DankMaterialShell/issues/1489
    dgop.package = let
      flake-dgop = pkgs.flake-compat {
        src = pkgs.fetchFromGitHub {
          owner = "AvengeMedia";
          repo = "dgop";
          rev = "3cd297080573319c36884b28a3cc0dbfed79f53e";
          hash = "sha256-NBGF7bo+nYSToDWtIXMwPeulzRxphX8JHzNRqLTOOqU=";
        };
      };
    in flake-dgop.defaultNix.packages.${pkgs.system}.default;
  };
}
