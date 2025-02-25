{ config, pkgs, stdenv, lib, ... }:
# gnome extensions and settings
# no need log out to reload extension: <alt>+F2 r
let
  opt = import ../../../opt.nix;
in{
  imports = [
    ./extensions/bing-wallpaper-changer.nix
    ./extensions/clipboard-indicator.nix
    ./extensions/gtile.nix
    ./extensions/unite.nix
  ];
  home.packages = (with pkgs; [
    gnome-sound-recorder
    dconf-editor
    devhelp
  ])
  ++ (with pkgs.gnomeExtensions; [
    hide-top-bar
    transparent-top-bar-adjustable-transparency
    dash-to-dock
    always-show-titles-in-overview
    customize-ibus
    # replace system-monitor(-next) with vitals
    # refers to https://github.com/mgalgs/gnome-shell-system-monitor-applet/issues/57
    # vitals
    system-monitor-next
    x11-gestures
  ]);

  # Setting: `gsettings set <key(dot)> <value>`
  # Getting: `dconf dump /<key(path)>`
  dconf.settings = {
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      ## enabled gnome extensions
      disable-user-extensions = false;
      disabled-extensions = [];
      enabled-extensions = [
        "hidetopbar@mathieu.bidon.ca"
        "transparent-top-bar@ftpix.com"
        # "Vitals@CoreCoding.com"
        "system-monitor-next@paradoxxx.zero.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "Always-Show-Titles-In-Overview@gmail.com"
        "customize-ibus@hollowman.ml"
        "x11gestures@joseexposito.github.io"
      ];

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
    ## extensions settings
    # "org/gnome/shell/extensions/vitals" = {
    #   fixed-widths = true;
    #   hide-icons = true;
    #   hot-sensors = [
    #     "_processor_usage_"
    #     "_memory_usage_"
    #     "__network-rx_max__"
    #     "__network-tx_max__"
    #   ];
    #   show-fan = false;
    #   show-system = false;
    #   show-temperature = false;
    #   show-voltage = false;
    #   update-time = 2;
    # };
    "org/gnome/shell/extensions/system-monitor" = {
      compact-display = true;
      icon-display = false;
      cpu-style = "digit";
      memory-style = "digit";
      net-style = "digit";
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
    "org/gnome/shell/extensions/hidetopbar" = {
      mouse-sensitive = true;
      enable-active-window=false;
      enable-intellihide=true;
      shortcut-delay = 0.0;
      shortcut-keybind = ["<Super>h"];
    };
    "com/ftpix/transparentbar" = {
      dark-full-screen = false;
      transparency = 40;
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      click-action="focus-or-appspread";
      transparency-mode = "FIXED";
      background-opacity = 0.4;
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

    # input method
    "org/gnome/desktop/input-sources" = {
      sources = with lib.hm.gvariant; mkArray
      "(${lib.concatStrings [type.string type.string]})" [
        (mkTuple ["xkb"  "us"])
        (mkTuple ["ibus" "rime"])
        (mkTuple ["ibus" "mozc-jp"])
        (mkTuple ["ibus" "hangul"])
      ];
    };
    "org/gnome/shell/extensions/customize-ibus" = {
      candidate-orientation = lib.hm.gvariant.mkUint32 1;
      custom-font="Iosevka Nerd Font 16";
      enable-orientation=true;
      input-indicator-only-on-toggle=false;
      input-indicator-only-use-ascii=false;
      use-custom-font=true;
      use-indicator-show-delay=true;
    };
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
