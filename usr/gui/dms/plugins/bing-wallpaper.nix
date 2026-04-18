{ pkgs, ... }: {
  programs.dank-material-shell.plugins = {
    wallpaperBing.src = pkgs.fetchFromGitHub {
      owner = "max72bra";
      repo = "DankPluginBingWallpaper";
      rev = "b6ed00fe037dec84cc4738e87eeec4fb9d4cfedf";
      hash = "sha256-30I7RZk5Wq4vJxL8753QnMG2rplw6b2iOR2vcSQmdw8=";
    };
  };
  yq-merge.".config/DankMaterialShell/plugin_settings.json".text = builtins.toJSON {
    wallpaperBing = {
      enabled = true;
    };
  };
}
