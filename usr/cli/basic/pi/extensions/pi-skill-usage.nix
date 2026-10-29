{ config, lib, pkgs, ... }: {
  # No runtime deps, and the entry lives at the repo root, so the pinned source
  # can be linked directly: pi labels the extension after the directory holding
  # its entry file, which is "pi-skill-usage" here.
  home.file.".pi/agent/extensions/pi-skill-usage".source = pkgs.npinsed.ai.pi.pi-skill-usage.outPath;

  # The ledger is written via temp-file + rename, which replaces a per-file
  # symlink, so the counts are shared through a symlinked directory instead.
  home.file.".pi/agent/skill-usage".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/skill-usage;
  # The temp file lives in that same directory; don't replicate it.
  my.syncthing.Gist-stignore = lib.mkAfter [ "/Data/pi/skill-usage/*.tmp" ];
}
