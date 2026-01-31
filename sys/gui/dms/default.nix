{ ... }: let
  pkgs = import <nixpkgs> {};
  # TODO: nixos-rebuild re-use config.nix?
  flake-compat = import (builtins.fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/0f9255e01c2351cc7d116c072cb317785dd33b33.tar.gz";
    sha256 = "0m9grvfsbwmvgwaxvdzv6cmyvjnlww004gfxjvcl806ndqaxzy4j";
  });
in {
  imports = [
    (let
      flake-dms = flake-compat {
        src = pkgs.fetchFromGitHub {
          owner = "AvengeMedia";
          repo = "DankMaterialShell";
          rev = "v1.2.3";
          hash = "sha256-P//moH3z9r4PXirTzXVsccQINsK5AIlF9RWOBwK3vLc=";
        };
      };
    in flake-dms.defaultNix.nixosModules.greeter)
  ];
  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/xieby1";
    configFiles = ["/home/xieby1/.config/DankMaterialShell/settings.json"];
  };
}
