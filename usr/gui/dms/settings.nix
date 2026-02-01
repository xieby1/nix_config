{ ... }: {
  yq-merge.".config/DankMaterialShell/settings.json".text = builtins.toJSON {
    showDock = true;
    dockAutoHide = true;
    dockOpenOnOverview = true;
    barConfigs = [{
      autoHide = true;
      showOnWindowsOpen = true;
      openOnOverview = true;
    }];
  };
}
