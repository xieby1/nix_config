{ pkgs, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.overrideAttrs (final: prev: {
        patches = [
          # # [feat: add window alignment actions#1929](https://github.com/niri-wm/niri/pull/1929)
          # (pkgs.fetchurl {
          #   name = "window-alignment";
          #   url = "https://github.com/niri-wm/niri/compare/d7184a04b904e07113f4623610775ae78d32394c..78d10a28e8a7a046e52ef16ad78bee4cdeee3d81.patch";
          #   sha256 = "18zjnp2hgh9wsiab0w5m90gvdx0i4ab8wvpgnf9y0qjza6shwi7d";
          # })
        ];
      });
    })
  ];
}
