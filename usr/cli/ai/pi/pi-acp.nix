{
  buildNpmPackage,
  npinsed,
}:
buildNpmPackage (finalAttrs: {
  name = "pi-acp";
  src = npinsed.ai.pi-acp;
  # pi-acp attempts to verify whether pi has authenticated to any models.
  # In my environment, none of the pi-acp check methods work,
  # because I hard-code the auth key in pi extensions.
  # Therefore, hasAnyPiAuthConfigured is made to return true directly.
  postPatch = ''
    sed -i '/function hasAnyPiAuthConfigured/a\  return true' src/pi-auth/status.ts
  '';
  npmDepsHash = "sha256-GuHvjqSD4M87cGBtFFSF37FWF79+6pLlai0A99Ii/hM=";
  npmRebuildFlags = [ "--ignore-scripts" ];
})

