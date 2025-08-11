#MC Input method
#MC
#MC Why replace ibus with fcitx5
#MC * ibus mozc not support shift toggle activation
#MC * ibus configuration use db, not file
#MC * ibus cannot be configured by user (home-manager)
{ config, pkgs, ... }: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = [
        pkgs.fcitx5-rime
        pkgs.fcitx5-mozc-ut
        pkgs.fcitx5-hangul
      ];
    };
  };

  imports = [ ./module.nix ];
  config_fcitx5 = {
    profile = (pkgs.formats.ini {}).generate "profile" {
      "Groups/0" = {
        Name="Default";
        "Default Layout"="us";
      };
      "Groups/0/Items/0" = {
        Name="keyboard-us";
      };
      "Groups/0/Items/1" = {
        Name="rime";
      };
      "Groups/0/Items/2" = {
        Name="mozc";
      };
      "Groups/0/Items/3" = {
        Name="hangul";
      };
    };
    config = (pkgs.formats.ini {}).generate "config" {
      "Hotkey" = {
        # Disable default super+space, shift+super+space
        EnumerateGroupForwardKeys="";
        EnumerateGroupBackwardKeys="";
      };
      "Hotkey/TriggerKeys" = {
        "0"="Shift_L";
      };
      "Hotkey/EnumerateForwardKeys" = {
        "0"="Control+space";
      };
      "Hotkey/EnumerateBackwardKeys" = {
        "0"="Control+Shift+space";
      };
    };
    "conf/classicui.conf" = (pkgs.formats.keyValue {}).generate "classicui.conf" {
      Font=''"Sans Serif 18"'';
      MenuFont=''"Sans Serif 16"'';
      TrayFont=''"Sans Serif 16"'';
      Theme="default";
      DarkTheme="default-dark";
      # Follow system light/dark color scheme
      UseDarkTheme="True";
      # Follow system accent color if it is supported by theme and desktop
      UseAccentColor="True";
    };
  };

  dconf.settings = {
    # Disable ibus input method shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source=[];
      switch-input-source-backward=[];
    };
  };
}
