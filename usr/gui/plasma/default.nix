{ pkgs, ... }: let
  plasma-manager = (import <nixpkgs> {}).fetchFromGitHub {
    owner = "nix-community";
    repo = "plasma-manager";
    rev = "51816be33a1ff0d4b22427de83222d5bfa96d30e";
    hash = "sha256-d5Q1GmQ+sW1Bt8cgDE0vOihzLaswsm8cSdg8124EqXE=";
  };
in {
  imports = [
    (plasma-manager + "/modules")
  ];
  programs = {
    plasma = {
      enable = true;
      # etc.
    };
  };
}
