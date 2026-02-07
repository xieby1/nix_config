{ pkgs, ... }: {
  imports = [
    (let
      # TODO: Why does `pkgs` above not work?
      pkgs = import <nixpkgs> {};
      flake-dms = pkgs.flake-compat {
        src = (pkgs.npinsed {input = ./npins.json;}).DankMaterialShell;
      };
    in flake-dms.defaultNix.homeModules.dank-material-shell)
    ./settings.nix
  ];
  programs.dank-material-shell = {
    enable = true;
    # https://github.com/AvengeMedia/DankMaterialShell/issues/1489
    dgop.package = let
      flake-dgop = pkgs.flake-compat {
        src = (pkgs.npinsed {input = ./npins.json;}).dgop;
      };
    in flake-dgop.defaultNix.packages.${builtins.currentSystem}.default;
  };
}
