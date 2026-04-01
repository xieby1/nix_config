{ pkgs, ... }: let
  settings-relpath = ".config/DankMaterialShell/settings.json";
in {
  yq-merge.${settings-relpath} = {
    preOnChange = ''
      if [[ ! -e ~/${settings-relpath} ]]; then
        cat ${import ./default-settings.nix} > ~/${settings-relpath}
      fi
      ${pkgs.yq-go}/bin/yq -i ' .barConfigs[0].leftWidgets=[]
                           | .barConfigs[0].centerWidgets=[]
                           | .barConfigs[0].rightWidgets=[]' ~/${settings-relpath}
    '';
    text = builtins.toJSON {
      currentThemeName = "dynamic";
      currentThemeCategory = "dynamic";
      cursorSettings.theme = "Adwaita";
      showDock = true;
      dockAutoHide = true;
      dockOpenOnOverview = true;
      barConfigs = [{
        autoHide = true;
        showOnWindowsOpen = true;
        openOnOverview = true;
        noBackground = true;
        spacing = 0;
        leftWidgets = [
          { enabled = true; id = "privacyIndicator"; }
          { enabled = true; id = "notificationButton"; }
          { enabled = true; id = "clipboard"; }
          { enabled = true; id = "wallpaperBing"; }
          { enabled = true; id = "separator"; }
          { enabled = true; id = "music"; }
          { enabled = true; id = "separator"; }
          { enabled = true; id = "focusedWindow"; }
        ];
        centerWidgets = [
          { enabled = true; id = "weather"; }
          { enabled = true; id = "spacer"; size = 10; }
          { enabled = true; id = "clock"; }
        ];
        rightWidgets = [
          { enabled = true; id = "systemTray"; }
          { enabled = true; id = "cpuUsage"; }
          { enabled = true; id = "memUsage"; showSwap = true; }
          { enabled = true; id = "diskUsage"; }
          { enabled = true; id = "network_speed_monitor"; }
          { enabled = true; id = "battery"; }
          { enabled = true; id = "controlCenterButton"; }
        ];
      }];
      notificationTimeoutLow = 5000;
      notificationTimeoutNormal = 0;
      notificationTimeoutCritical = 0;
    };
  };
}
