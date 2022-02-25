{ config, pkgs, stdenv, lib, ... }:
# gnome extensions and settings
let
  exts = with pkgs.gnomeExtensions; [
    dash-to-dock
    system-monitor
    vertical-overview
    unite
  ];
  exts40 = with pkgs; [
    gnome40Extensions."BingWallpaper@ineffable-gmail.com"
    gnome40Extensions."clipboard-indicator@tudmotu.com"
    gnome40Extensions."gTile@vibou"
    gnome40Extensions."hidetopbar@mathieu.bidon.ca"
  ];
in
{
  home.packages = (with pkgs; [
    gnome.gnome-sound-recorder
  ])
  ++ exts
  ++ exts40;

  # gnome-terminal
  ## dconf dump /org/gnome/terminal/legacy/profiles:/
  programs.gnome-terminal.enable = true;
  programs.gnome-terminal.profile = {
    "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      visibleName = "xieby1";
      default = true;
      font = "Monospace 18";
      # Tango
      colors = {
        foregroundColor = "rgb(211,215,207)";
        backgroundColor = "rgb(46,52,54)";
        palette = [
          "rgb(46,52,54)" "rgb(204,0,0)" "rgb(78,154,6)" "rgb(196,160,0)" "rgb(52,101,164)" "rgb(117,80,123)" "rgb(6,152,154)" "rgb(211,215,207)" "rgb(85,87,83)" "rgb(239,41,41)" "rgb(138,226,52)" "rgb(252,233,79)" "rgb(114,159,207)" "rgb(173,127,168)" "rgb(52,226,226)" "rgb(238,238,236)"
        ];
      };
    };
  };

  # Setting: `gsettings set <key(dot)> <value>`
  # Getting: `dconf dump /<key(path)>`
  dconf.settings = {
    "org/gnome/shell" = {
      ## enabled gnome extensions
      disable-user-extensions = false;
      enabled-extensions = [
        "BingWallpaper@ineffable-gmail.com"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "gTile@vibou"
        "hidetopbar@mathieu.bidon.ca"
        "system-monitor@paradoxxx.zero.gmail.com"
        "vertical-overview@RensAlthuis.github.com"
        "unite@hardpixel.eu"
      ];

      ## dock icons
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "google-chrome.desktop"
        "org.gnome.Epiphany.desktop"
        "spotify.desktop"
        ];
    };
    ## extensions settings
    "org/gnome/shell/extensions/system-monitor" = {
      compact-display=true;
      cpu-show-text=false;
      cpu-style="digit";
      icon-display=false;
      memory-show-text=false;
      memory-style="digit";
      net-show-text=false;
      net-style="digit";
      swap-display=false;
      swap-style="digit";
    };
    "org/gnome/shell/extensions/vertical-overview" = {
      override-dash=false;
    };
    "org/gnome/shell/extensions/gtile" = {
      animation=true;
      global-presets=true;
      grid-sizes="6x4,8x6";
      preset-resize-1=["<Super>bracketleft"];
      preset-resize-2=["<Super>bracketright"];
      preset-resize-3=["<Super>period"];
      preset-resize-4=["<Super>slash"];
      preset-resize-5=["<Super>apostrophe"];
      resize1="2x2 0:0 0:0";
      resize2="2x2 1:0 1:0";
      resize3="2x2 0:1 0:1";
      resize4="2x2 1:1 1:1";
      resize5="4x8 1:1 2:6";
      show-icon=false;
    };

    "org/gnome/desktop/session" = {
      idle-delay=lib.hm.gvariant.mkUint32 0; # never turn off screen
    };
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled=false;
      idle-dim=false;
      power-button-action="suspend";
      sleep-inactive-ac-timeout=3600;
      sleep-inactive-ac-type="nothing";
      sleep-inactive-battery-type="suspend";
    };
    "org/gnome/shell/extensions/hidetopbar" = {
      mouse-sensitive = true;
      enable-active-window=false;
      enable-intellihide=false;
    };
    "org/gnome/shell/extensions/unite" = {
      app-menu-ellipsize-mode="end";
      extend-left-box=false;
      greyscale-tray-icons=false;
      hide-app-menu-icon=false;
      hide-dropdown-arrows=true;
      hide-window-titlebars="both";
      notifications-position="center";
      reduce-panel-spacing=true;
      show-window-buttons="always";
      window-buttons-placement="last";
      window-buttons-theme="materia";
    };

    # customized keyboard shortcuts
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings=[
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding="<Primary><Alt>t";
      command="gnome-terminal";
      name="terminal";
    };

    # predefined keyboard shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications=[];
      switch-applications-backward=[];
      switch-windows=["<Alt>Tab"];
      switch-windows-backward=["<Shift><Alt>Tab"];
      maximize=["<Super>Up"];
      unmaximize=["<Super>Down"];
      move-to-workspace-up=["<Primary>Page_Up"];
      move-to-workspace-down=["<Primary>Page_Down"];
      switch-to-workspace-up=["<Primary><Alt>Up"];
      switch-to-workspace-down=["<Primary><Alt>Down"];
    };

    # nautilus
    "org/gtk/settings/file-chooser" = {
      sort-directories-first=true;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners=false;
      show-battery-percentage=true;
    };
  };
}
