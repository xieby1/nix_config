{ pkgs, ... }: {
  programs.dank-material-shell.plugins = {
    dms-unified-taskbar.src = pkgs.applyPatches {
      name = "dms-unified-taskbar-patched";
      src = pkgs.npinsed.de.dms-unified-taskbar;
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
