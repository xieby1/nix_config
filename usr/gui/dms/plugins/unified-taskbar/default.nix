{ pkgs, ... }: {
  programs.dank-material-shell.plugins = {
    dms-unified-taskbar.src = pkgs.applyPatches {
      name = "dms-unified-taskbar-patched";
      src = pkgs.npinsed.de.dms-unified-taskbar;
      # DankRipple was introduced in DMS v1.4.0 (commit 37cc4ab1), so this patch removes its usage
      # for compatibility with older DMS versions (< 1.4.0). The ripple effect is cosmetic only.
      # TODO: Remove this patch once DMS dependency is bumped to >= 1.4.0
      patches = [./remove-DankRipple.patch];
    };
  };
  yq-merge.".config/DankMaterialShell/plugin_settings.json" = {
    generator = builtins.toJSON;
    expr = {
      unifiedTaskbar = {
        enabled = true;
        compactMode = true;
        allMonitors = false;
      };
    };
  };
}
