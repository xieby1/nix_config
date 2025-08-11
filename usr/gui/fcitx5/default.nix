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
  home.file.fcitx5_profile = let
    relDir = ".config/fcitx5";
    absDir = "${config.home.homeDirectory}/${relDir}";
  in {
    target = "${relDir}/_profile_";
    source = (pkgs.formats.ini {}).generate "profile" {
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
    onChange = ''
      if [[ -e ${absDir}/profile ]]; then
        ${pkgs.crudini}/bin/crudini --merge ${absDir}/profile < ${absDir}/_profile_
      else
        cat ${absDir}/_profile_ > ${absDir}/profile
      fi
    '';
  };
  home.file.fcitx5_config = let
    relDir = ".config/fcitx5";
    absDir = "${config.home.homeDirectory}/${relDir}";
  in {
    target = "${relDir}/_config_";
    source = (pkgs.formats.ini {}).generate "config" {
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
    onChange = ''
      if [[ -e ${absDir}/config ]]; then
        ${pkgs.crudini}/bin/crudini --merge ${absDir}/config < ${absDir}/_config_
      else
        cat ${absDir}/_config_ > ${absDir}/config
      fi
    '';
  };
  home.file.fcitx5_conf_classicui_conf = let
    relDir = ".config/fcitx5";
    absDir = "${config.home.homeDirectory}/${relDir}";
  in {
    target = "${relDir}/conf/_classicui.conf_";
    source = (pkgs.formats.keyValue {}).generate "classicui.conf" {
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
    onChange = ''
      if [[ -e ${absDir}/conf/classicui.conf ]]; then
        ${pkgs.crudini}/bin/crudini --merge ${absDir}/conf/classicui.conf < ${absDir}/conf/_classicui.conf_
      else
        cat ${absDir}/conf/_classicui.conf_ > ${absDir}/conf/classicui.conf
      fi
    '';
  };

  dconf.settings = {
    # Disable ibus input method shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source=[];
      switch-input-source-backward=[];
    };
  };
}
