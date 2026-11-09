{ npinsFun, ... }: {
  home.file.".config/DankMaterialShell/plugins/wallpaperBing".source = (npinsFun {input=./sources.json;}).DankPluginBingWallpaper;
  yq-merge.".config/DankMaterialShell/plugin_settings.json" = { generator = builtins.toJSON; expr = {
    wallpaperBing = {
      enabled = true;
    };
  };};
}
