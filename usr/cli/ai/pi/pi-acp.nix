{
  buildNpmPackage,
  npinsed,
}:
buildNpmPackage (finalAttrs: {
  name = "pi-acp";
  src = npinsed.ai.pi-acp;
  # Patch pi-acp to support standard ACP model switching:
  # - Upgrades @agentclientprotocol/sdk from 0.12.0 to 0.19.0 for setSessionConfigOption support
  # - Adds configOptions (category: "model") to session/new and session/load responses
  # - Implements setSessionConfigOption handler so clients like codecompanion.nvim can switch models
  # - Retains backward compatibility (unstable_setSessionModel and models field)
  patches = [./model-switching.patch];
  # pi-acp attempts to verify whether pi has authenticated to any models.
  # In my environment, none of the pi-acp check methods work,
  # because I hard-code the auth key in pi extensions.
  # Therefore, hasAnyPiAuthConfigured is made to return true directly.
  postPatch = ''
    sed -i '/function hasAnyPiAuthConfigured/a\  return true' src/pi-auth/status.ts
  '';
  npmDepsHash = "sha256-bKqXuCqgZCnG/yfFLDwxNZNpvAuCssTlsKe+8tYiCVE=";
  npmRebuildFlags = [ "--ignore-scripts" ];
})

