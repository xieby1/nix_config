{ pkgs, ... }: let
  pi-continuous-learning-build = pkgs.buildNpmPackage (finalAttrs: {
    name = "pi-continuous-learning";
    src = pkgs.npinsed.ai.mattdevy-pi-extensions + /packages/pi-continuous-learning;
    prePatch = ''
      ln -s ${pkgs.npinsed.ai.mattdevy-pi-extensions}/package-lock.json .
    '';
    npmDepsHash = "sha256-y9l3HhKz6Gq7EgXuhU4ESGbFyWVA3izvgpdWzuV6NzA=";
    npmFlags = [ "--legacy-peer-deps" ];
  });
in {
  home.packages = [pi-continuous-learning-build];
  home.file = {
    pi-continuous-learning = {
      target = ".pi/agent/extensions/pi-continuous-learning";
      source = pi-continuous-learning-build + /lib/node_modules/pi-continuous-learning;
    };
  };
}
