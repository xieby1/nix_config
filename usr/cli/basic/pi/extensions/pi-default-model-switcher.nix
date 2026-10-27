{ pkgs, ... }:
{
  # No runtime dependencies; Pi provides the peer packages.
  home.file.".pi/agent/extensions/pi-default-model-switcher".source =
    pkgs.npinsed.ai.pi.pi-default-model-switcher.outPath;
}
