{ pkgs, ... }: {
  # No runtime deps and the entry is the repo root index.ts, so link the pin
  # directly; pi labels the extension after the directory holding the entry.
  home.file.".pi/agent/extensions/pi-powerline-footer".source = pkgs.applyPatches {
    name = "pi-powerline-footer";
    src = pkgs.npinsed.ai.pi.pi-powerline-footer;
    patches = [ ./flush-editor-and-tight-separators.patch ];
  };

  # Default preset with `path` hoisted to the front and `separator = "none"`
  # (a plain space, so segments read as colored words). A layout `left` array
  # replaces the preset group exactly, hence the full default left list
  # repeated here with `path` moved first.
  yq-merge.".pi/agent/settings.json".expr.powerline = {
    preset = "default";
    separator = "none";
    # Default 1 space per edge is visible because the bar sits flush with
    # pi's own full-width borders.
    padding = 0;
    layout.left = [
      "path"
      "model"
      "thinking"
      "shell_mode"
      "git"
      "queue"
      "context_pct"
      "cache_read"
      "cost"
    ];
  };
}
