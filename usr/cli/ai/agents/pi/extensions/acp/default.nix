{
  buildNpmPackage,
  npinsed,
}:
buildNpmPackage (finalAttrs: {
  name = "pi-acp";
  src = npinsed.ai.pi.acp;
  npmDepsHash = "sha256-qN+b/tMbnJLkWjotl3XrA0nfZ3KT/mT6gM+n3Qiz8Wk=";
  npmRebuildFlags = [ "--ignore-scripts" ];
})

