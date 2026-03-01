let
  flake-compat = import (builtins.fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/0f9255e01c2351cc7d116c072cb317785dd33b33.tar.gz";
    sha256 = "0m9grvfsbwmvgwaxvdzv6cmyvjnlww004gfxjvcl806ndqaxzy4j";
  });
  fabric-flake = flake-compat {
   src = (import <nixpkgs> {}).fetchFromGitHub {
      owner = "Fabric-Development";
      repo = "fabric";
      rev = "7809cc831c701531ea1461b5f0da11c13d78612e";
      hash = "sha256-JkScB31Iq9A3mB4dHTskMTir31pm2AkcpTSU8PIG+qs=";
    };
  };
  pkgs = import fabric-flake.defaultNix.inputs.nixpkgs.outPath {};
  fabric = fabric-flake.defaultNix.packages."${builtins.currentSystem}".default;
in pkgs.mkShell {
  name = "fabric";
  packages = [
    fabric
    pkgs.gtk3
  ];
}
