{ pkgs, ... }: {
  nixpkgs.overlays = [
    (pkgs-final: pkgs-prev: {
      niri = pkgs-prev.niri.overrideAttrs (niri-final: niri-prev: {
        patches = niri-prev.patches ++ [
          # [feat: add column alignment actions #3033](https://github.com/niri-wm/niri/pull/3033)
          (pkgs.fetchurl {
            name = "column-alignment";
            url = "https://github.com/niri-wm/niri/commit/7ac6abd0b42422bc79c2a67309c16bbb2be48176.patch";
            sha256 = "sha256-5+3R97TyBFF9KP+1ECpiMdvedxWllHXepvGY064cNAw=";
          })
          (pkgs.fetchurl {
            name = "column-alignment-floating-fix";
            url = "https://github.com/niri-wm/niri/commit/7aa5e4cab76eb6164bc930336cb6ac7bdd362668.patch";
            sha256 = "sha256-Fx3x2hhBxW2UmYbJVL96ZgxaPWK1oSE2Uzm6qywFFqE=";
          })
        ];
      });
    })
  ];
}
