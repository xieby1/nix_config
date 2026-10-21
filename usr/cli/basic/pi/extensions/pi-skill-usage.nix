{ pkgs, ... }: {
  # No runtime deps, and the entry lives at the repo root, so the pinned source
  # can be linked directly: pi labels the extension after the directory holding
  # its entry file, which is "pi-skill-usage" here.
  home.file.".pi/agent/extensions/pi-skill-usage".source = pkgs.npinsed.ai.pi.pi-skill-usage.outPath;
}
