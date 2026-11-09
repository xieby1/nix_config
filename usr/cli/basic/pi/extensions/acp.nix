{ src }: # local-args
{ pkgs, ... }: {
  home.packages = [(
    pkgs.buildNpmPackage (finalAttrs: {
      name = "pi-acp";
      inherit src;
      npmDepsHash = "sha256-BvLNtFfp1cMVjzWcMRSdhTqiJrTfbFoUbWkkPW9200o=";
      npmRebuildFlags = [ "--ignore-scripts" ];
    })
  )];
}
