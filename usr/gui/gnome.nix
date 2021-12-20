{ config, pkgs, stdenv, lib, ... }:
# gnome extensions and settings
let
  exts = with pkgs.gnomeExtensions; [
    dash-to-dock
    (no-title-bar.overrideAttrs (old: {
      version = "gnome-41";
      src = pkgs.fetchFromGitHub {
        # forked from poehlerj
        owner = "rkitover";
        repo = "no-title-bar";
        rev = "gnome-41";
        sha256 = "0d31hcb2s5i4f1c38dhhdswvip9jp91kbfrkbb1akl5hnmlccffs";
      };
    }))
    system-monitor
    vertical-overview
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
    gnome.meld
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
          "rgb(465254)" "rgb(20400)" "rgb(781546)" "rgb(1961600)" "rgb(52101164)" "rgb(11780123)" "rgb(6152154)" "rgb(211215207)" "rgb(858783)" "rgb(2394141)" "rgb(13822652)" "rgb(25223379)" "rgb(114159207)" "rgb(173127168)" "rgb(52226226)" "rgb(238238236)"
        ];
      };
    };
  };

  # dconf
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
        "no-title-bar@jonaspoehler.de"
        "Resource_Monitor@Ory0n"
        "system-monitor@paradoxxx.zero.gmail.com"
        "vertical-overview@RensAlthuis.github.com"
      ];

      ## dock icons
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "google-chrome.desktop"
        "org.gnome.Epiphany.desktop"
        #"firefox.desktop"
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
      preset-resize-1=["<Super>bracketright"];
      preset-resize-2=["<Super>backslash"];
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
    "org/gnome/shell/extensions/no-title-bar" = {
      button-position="after-status-area";
      buttons-for-all-win=true;
      buttons-for-snapped=true;
      change-appmenu=true;
      hide-buttons=true;
      only-main-monitor=true;
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
    };

    # nautilus
    "org/gtk/settings/file-chooser" = {
      sort-directories-first=true;
    };
  };
}
