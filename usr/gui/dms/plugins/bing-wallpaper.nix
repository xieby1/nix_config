{ pkgs, ... }: {
  home.file.".config/DankMaterialShell/plugins/wallpaperBing".source = pkgs.npinsed.de.DankPluginBingWallpaper;
  yq-merge.".config/DankMaterialShell/plugin_settings.json" = { generator = builtins.toJSON; expr = {
    wallpaperBing = {
      enabled = true;
    };
  };};
}
