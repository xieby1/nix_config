let
  pkgs = import <nixpkgs> {};
in (pkgs.flake-compat {
  src = pkgs.applyPatches {
    name = "patched-goose-source";
    src = pkgs.npinsed.ai.goose;
    patches = [
      # fix(flake): #8514 - added output hashes to flake.nix ...#9319
      (builtins.fetchurl {
        url = "https://github.com/aaif-goose/goose/pull/9319.patch";
        sha256 = "0ca1bnn680br8i98c27h9w3ppyqqpscbxhm8mprxyd7chw40xj2a";
      })
      # feat: add /model slash command to CLI for session model switching#8747
      # Cons: only support change model, cannot change provider, cannot auto completion
      (builtins.fetchurl {
        url = "https://github.com/aaif-goose/goose/pull/8747.patch";
        sha256 = "1d68gwhz2037abkri5kgl6a1fgafcribw7iz8r6ln6si02qqvlqi";
      })
    ];
  };
}).defaultNix.packages.${pkgs.stdenv.system}.default
