let
  hm_aarch64 = import <home-manager/modules> {
    configuration = ~/.config/home-manager/home.nix;
    pkgs = import <nixpkgs> {
      localSystem.system="aarch64-linux";
      crossSystem="aarch64-linux";
    };
  };
  pkgs = import <nixpkgs> {};
in
  # TODO: only push minimal config
  builtins.filter (e: ! pkgs.lib.hasInfix "niri" e )
  hm_aarch64.config.cachix_packages
