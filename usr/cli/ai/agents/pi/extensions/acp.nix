{ pkgs, ... }: {
  home.packages = [(
    pkgs.buildNpmPackage (finalAttrs: {
      name = "pi-acp";
      src = pkgs.npinsed.ai.pi.acp;
      npmDepsHash = "sha256-qN+b/tMbnJLkWjotl3XrA0nfZ3KT/mT6gM+n3Qiz8Wk=";
      npmRebuildFlags = [ "--ignore-scripts" ];
    })
  )];
}
