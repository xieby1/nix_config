{ ... }: {
  imports = [
    ./bing-wallpaper.nix
    ./unified-taskbar
  ];
  yq-merge.".config/DankMaterialShell/plugin_settings.json" = {
    preOnChange = ''
      if [[ ! -e ~/.config/DankMaterialShell/plugin_settings.json ]]; then
        echo '{}' > ~/.config/DankMaterialShell/plugin_settings.json
      fi
    '';
  };
}
