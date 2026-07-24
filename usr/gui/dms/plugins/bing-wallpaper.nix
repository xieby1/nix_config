{ pkgs, ... }: {
  programs.dank-material-shell.plugins = {
    wallpaperBing.src = pkgs.npinsed.de.DankPluginBingWallpaper;
  };
  yq-merge.".config/DankMaterialShell/plugin_settings.json" = { generator = builtins.toJSON; expr = {
    wallpaperBing = {
      enabled = true;
    };
  };};
}
