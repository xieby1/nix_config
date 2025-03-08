#MC Gnome settings
{ pkgs, lib, ... }:
let
  opt = import ../../../opt.nix;
in {
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
        "microsoft-edge.desktop"
        "calendar.desktop"
        "todo.desktop"
        "google-chrome.desktop"
      ];
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
      move-to-workspace-left=["<Control>Home"];
      move-to-workspace-right=["<Control>End"];
    };

    # nautilus
    "org/gtk/settings/file-chooser" = {
      sort-directories-first=true;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners=false;
      show-battery-percentage=true;
      switch-input-source=["<Control>space"];
      switch-input-source-backward=["<Shift><Control>space"];
    };

    # proxy
    "system/proxy" = {mode = "manual";};
    "system/proxy/ftp" = {host="127.0.0.1"; port=opt.proxyPort;};
    "system/proxy/http" = {host="127.0.0.1"; port=opt.proxyPort;};
    "system/proxy/https" = {host="127.0.0.1"; port=opt.proxyPort;};

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };
  };

  # inspired by https://discourse.nixos.org/t/how-to-set-the-bookmarks-in-nautilus/36143
  home.activation.nautilus_bookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # WSL2 may not have folder ~/.config/gtk-3.0
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/gtk-3.0
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG ~/Gist/Config/nautilus_bookmarks ~/.config/gtk-3.0/bookmarks
  '';
}
