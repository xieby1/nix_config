{
  buildNpmPackage,
  npinsed,
}:
buildNpmPackage (finalAttrs: {
  name = "pi-acp";
  src = (npinsed {input=../npins/sources.json;}).pi-acp;
  npmDepsHash = "sha256-GuHvjqSD4M87cGBtFFSF37FWF79+6pLlai0A99Ii/hM=";
  npmRebuildFlags = [ "--ignore-scripts" ];
})

