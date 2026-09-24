{ pkgs, ... }: {
  home.packages = [(
    pkgs.buildNpmPackage (finalAttrs: {
      name = "pi-acp";
      src = pkgs.npinsed.ai.pi.acp;
      npmDepsHash = "sha256-/fX79XucKojL/6gZbK5eizEfrXso8rlTgiHfJffmDuY=";
      npmRebuildFlags = [ "--ignore-scripts" ];
    })
  )];
}
