{ config, pkgs, stdenv, lib, ... }:
# gnome extensions and settings
# no need log out to reload extension: <alt>+F2 r
{
  home.packages = (with pkgs; [
    gnome.gnome-sound-recorder
  ])
  ++ (with pkgs.gnomeExtensions; [
    system-monitor
    unite
    clipboard-indicator
    bing-wallpaper-changer
    gtile
    hide-top-bar
  ]);

  # Setting: `gsettings set <key(dot)> <value>`
  # Getting: `dconf dump /<key(path)>`
  dconf.settings = {
    "org/gnome/shell" = {
      ## enabled gnome extensions
      disable-user-extensions = false;
      enabled-extensions = [
        "BingWallpaper@ineffable-gmail.com"
        "clipboard-indicator@tudmotu.com"
        "gTile@vibou"
        "hidetopbar@mathieu.bidon.ca"
        "system-monitor@paradoxxx.zero.gmail.com"
        "unite@hardpixel.eu"
      ];

      ## dock icons
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "google-chrome.desktop"
        "org.qutebrowser.qutebrowser.desktop"
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
    "org/gnome/shell/extensions/gtile" = {
      animation=true;
      global-presets=true;
      grid-sizes="6x4,8x6";
      preset-resize-1=["<Super>bracketleft"];
      preset-resize-2=["<Super>bracketright"];
      preset-resize-3=["<Super>period"];
      preset-resize-4=["<Super>slash"];
      preset-resize-5=["<Super>apostrophe"];
      preset-resize-6=["<Super>semicolon"];
      preset-resize-7=["<Super>comma"];
      resize1="2x2 1:1 1:1";
      resize2="2x2 2:1 2:1";
      resize3="2x2 1:2 1:2";
      resize4="2x2 2:2 2:2";
      resize5="4x8 2:2 3:7";
      resize6="1x2 1:1 1:1";
      resize7="1x2 1:2 1:2";
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
      enable-intellihide=true;
    };
    "org/gnome/shell/extensions/unite" = {
      app-menu-ellipsize-mode="end";
      extend-left-box=false;
      greyscale-tray-icons=false;
      hide-app-menu-icon=false;
      hide-dropdown-arrows=true;
      hide-window-titlebars="always";
      notifications-position="center";
      reduce-panel-spacing=true;
      show-window-buttons="always";
      window-buttons-placement="last";
      window-buttons-theme="materia";
      restrict-to-primary-screen=false;
    };
    "org/gnome/shell/extensions/bingwallpaper" = {
      market="zh-CN";
      delete-previous=false;
    };

    # customized keyboard shortcuts
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings=[
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding="<Primary><Alt>t";
      # use tango color black       white        black, new tab pos
      # command=''
      #   tabbed -c -t "#2e3436" -o "#d3d7cf" -O "#2e3436" -p s+1 alacritty --embed
      # '';
      command = "kitty";
      name="terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding="<Alt>space";
      command="~/Gist/script/bash/quteapp.sh cheatsheet ~/Documents/Tech/my_cheatsheet.html";
      name="cheatsheet";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding="<Alt>c";
      command="~/Gist/script/bash/singleton.sh my_cheatsheet.mkd kitty vim ${config.home.homeDirectory}/Documents/Tech/my_cheatsheet.mkd";
      name="edit cheatsheet";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding="<Alt>b";
      command="~/Gist/script/bash/quteapp.sh bing https://cn.bing.com/dict/";
      name="bing dict";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding="<Alt>j"; command="~/Gist/script/bash/quteapp.sh 日语词典 https://dict.hjenglish.com/jp/";
      name="日语词典";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding="<Alt>k"; command="~/Gist/script/bash/singleton.sh kdeconnect.app kdeconnect-app";
      name="KDE Connect";
    };

    # predefined keyboard shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications=[];
      switch-applications-backward=[];
      switch-windows=["<Alt>Tab"];
      switch-windows-backward=["<Shift><Alt>Tab"];
      maximize=["<Super>Up"];
      unmaximize=["<Super>Down"];
      move-to-workspace-left=["<Control>Home"];
      move-to-workspace-right=["<Control>End"];
    };
    "org/gnome/shell/extensions/clipboard-indicator" =
    {
      move-item-first=true;
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
