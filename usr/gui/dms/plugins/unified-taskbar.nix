{ pkgs, ... }: {
  home.file.".config/DankMaterialShell/plugins/dms-unified-taskbar".source = pkgs.npinsed.de.dms-unified-taskbar;
  yq-merge.".config/DankMaterialShell/plugin_settings.json" = {
    generator = builtins.toJSON;
    expr = {
      unifiedTaskbar = {
        enabled = true;
        compactMode = true;
        allMonitors = false;
        iconPadding = 4;
        itemSpacing = 0;
        workspaceSpacing = 0;
      };
    };
  };
}
