#MC Gnome settings
{ config, pkgs, lib, ... }: {
  imports = [
    ./calendar
    ./extensions
  ];
  home.packages = with pkgs; [
    gnome-sound-recorder
    dconf-editor
    devhelp
  ];

  # Setting: `gsettings set <key(dot)> <value>`
  # Getting: `dconf dump /<key(path)>`
  dconf.settings = {
    "org/gnome/shell" = {
      ## dock icons
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "firefox-single-tab.desktop"
        "chromium-browser.desktop"
        "wangyiyunyinyue-wyyyy.desktop"
        "spotify.desktop"
      ];
    };
    "org/gnome/shell/keybindings" = {
      # disable original super+A
      toggle-application-view = [];
    };

    "org/gnome/desktop/session" = {
      idle-delay=lib.hm.gvariant.mkUint32 0; # never turn off screen
    };
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled=false;
      idle-dim=false;
      power-button-action="nothing";
      sleep-inactive-ac-timeout=3600;
      sleep-inactive-ac-type="nothing";
      sleep-inactive-battery-type="suspend";
    };

    # predefined keyboard shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications=[];
      switch-applications-backward=[];
      switch-windows=["<Alt>Tab"];
      switch-windows-backward=["<Shift><Alt>Tab"];
      maximize=["<Super>Up"];
      unmaximize=["<Super>Down"];
      minimize=[];
      move-to-workspace-left=["<Control><Super>Left"];
      move-to-workspace-right=["<Control><Super>Right"];
      # Disable alt+space binding
      activate-window-menu=[];
    };

    # nautilus
    "org/gtk/settings/file-chooser" = {
      sort-directories-first=true;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners=false;
      show-battery-percentage=true;
      clock-show-weekday=true;
    };

    # proxy
    "system/proxy" = {mode = "manual";};
    "system/proxy/ftp" = {host="127.0.0.1"; port=config.proxyPort;};
    "system/proxy/http" = {host="127.0.0.1"; port=config.proxyPort;};
    "system/proxy/https" = {host="127.0.0.1"; port=config.proxyPort;};

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };
  };

  systemd.user.tmpfiles.rules = [
    "L? %h/.config/gtk-3.0/bookmarks - - - - %h/Gist/Config/nautilus_bookmarks"
  ];
}
