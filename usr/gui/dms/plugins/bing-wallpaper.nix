{ ... }: {
  home.file.".config/DankMaterialShell/plugins/wallpaperBing".source = (import <npins> {input=./sources.json;}).DankPluginBingWallpaper;
  yq-merge.".config/DankMaterialShell/plugin_settings.json" = { generator = builtins.toJSON; expr = {
    wallpaperBing = {
      enabled = true;
    };
  };};
}
