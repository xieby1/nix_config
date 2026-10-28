{ pkgs, ... }: {
  # No runtime deps and the entry is the repo root index.ts, so link the pin
  # directly; pi labels the extension after the directory holding the entry.
  home.file.".pi/agent/extensions/pi-powerline-footer".source =
    pkgs.npinsed.ai.pi.pi-powerline-footer.outPath;
}
