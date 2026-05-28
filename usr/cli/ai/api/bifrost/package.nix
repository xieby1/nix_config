# - Cons:
#   - bifrost git repo is huge, the nix build needs to download hugh amount of npmDeps.
#   - The simple nix bug fix is very slow: https://github.com/maximhq/bifrost/issues/2192
let
  pkgs = import <nixpkgs> {};
  bifrost-pkgs = (pkgs.flake-compat { src = pkgs.npinsed.ai.bifrost; })
                  .defaultNix.packages.${pkgs.stdenv.system};
# See: https://github.com/maximhq/bifrost/issues/2192
in (bifrost-pkgs.bifrost-http.override {
  bifrost-ui = bifrost-pkgs.bifrost-ui.overrideAttrs (old: {
    npmDeps = old.npmDeps.overrideAttrs (_: {
      outputHash = "sha256-YniwFXRYyS8PpfabAAK0csyQLGrwUjONLTGXF7HINaI=";
    });
  });
}).overrideAttrs (old: {
  goModules = old.goModules.overrideAttrs (_: {
    outputHash = "sha256-yHoZK5cfDYCCZCmBm0a849wKEDXcYnNWN16kfCdwK7w=";
  });
})
