{ pkgs, ... }: {
  # No runtime deps and pi loads src/index.ts itself, so link the pinned source
  # directly instead of going through buildNpmPackage.
  home.file.".pi/agent/extensions/pi-tool-stats".source = pkgs.npinsed.ai.pi.pi-tool-stats.outPath;
}
