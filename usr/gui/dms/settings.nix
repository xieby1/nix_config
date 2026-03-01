{ ... }: let
  settings-relpath = ".config/DankMaterialShell/settings.json";
in {
  yq-merge.${settings-relpath} = {
    preOnChange = ''
      if [[ ! -e ~/${settings-relpath} ]]; then
        cat ${import ./default-settings.nix} > ~/${settings-relpath}
      fi
    '';
    text = builtins.toJSON {
      showDock = true;
      dockAutoHide = true;
      dockOpenOnOverview = true;
      barConfigs = [{
        autoHide = true;
        showOnWindowsOpen = true;
        openOnOverview = true;
        leftWidgets = [
          { enabled = true; id = "launcherButton"; }
          { enabled = true; id = "wallpaperBing"; }
          # { enabled = true; id = "workspaceSwitcher"; }
          { enabled = true; id = "network_speed_monitor"; }
          { enabled = true; id = "focusedWindow"; }
        ];
        centerWidgets = [
          { enabled = true; id = "music"; }
          { enabled = true; id = "clock"; }
          { enabled = true; id = "weather"; }
          { enabled = true; id = "privacyIndicator"; }
        ];
        rightWidgets = [
          { enabled = true; id = "systemTray"; }
          { enabled = true; id = "cpuUsage"; }
          { enabled = true; id = "memUsage"; showSwap = true; }
          { enabled = true; id = "diskUsage"; }
          { enabled = true; id = "clipboard"; }
          { enabled = true; id = "notificationButton"; }
          { enabled = true; id = "battery"; }
          { enabled = true; id = "controlCenterButton"; }
        ];
      }];
    };
  };
}
