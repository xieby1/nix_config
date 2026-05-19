{ pkgs, lib, ... }: let
  goose-unwrapped = (pkgs.flake-compat {
    src = pkgs.applyPatches {
      name = "patched-goose-source";
      src = pkgs.npinsed.ai.goose;
      patches = [
        # fix(flake): #8514 - added output hashes to flake.nix ...#9319
        (builtins.fetchurl {
          url = "https://github.com/aaif-goose/goose/pull/9319.patch";
          sha256 = "0ca1bnn680br8i98c27h9w3ppyqqpscbxhm8mprxyd7chw40xj2a";
        })
      ];
    };
  }).defaultNix.packages.${pkgs.stdenv.system}.default;
  goose-wrapped = pkgs.runCommand "goose-wrapped" {
    nativeBuildInputs = [pkgs.makeWrapper];
    passthru.unwrapped = goose-unwrapped;
  } ''
    mkdir -p $out
    ${pkgs.xorg.lndir}/bin/lndir -silent ${goose-unwrapped} $out
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --set GOOSE_DISABLE_KEYRING 1
    done
  '';
in {
  home.packages = [ goose-wrapped ];
  cachix_packages = [ goose-unwrapped ];
  programs.zsh.initContent = lib.mkAfter ''
    eval "$(goose completion zsh)"
  '';
}
