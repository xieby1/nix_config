{ pkgs, ... }: {
  home.packages = [(
    pkgs.buildNpmPackage (finalAttrs: {
      name = "pi-acp";
      src = pkgs.npinsed.ai.pi.acp;
      npmDepsHash = "sha256-BvLNtFfp1cMVjzWcMRSdhTqiJrTfbFoUbWkkPW9200o=";
      npmRebuildFlags = [ "--ignore-scripts" ];
    })
  )];
}
