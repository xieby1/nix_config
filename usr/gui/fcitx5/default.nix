#MC Input method
#MC
#MC Why replace ibus with fcitx5
#MC * ibus mozc not support shift toggle activation
#MC * ibus configuration use db, not file
#MC * ibus cannot be configured by user (home-manager)
{ pkgs, ... }: let
  # 自建拼音字典
  #   参考：https://wiki.archlinux.org/title/Fcitx5
  #         https://github.com/fcitx/libime/blob/master/tools/libime_pinyindict.cpp
  #         TLDR: libime_pinyindict：语法: 词 pin'yin 频率
  my-dict = pkgs.runCommand "my-fcitx-dict" {} ''
    DIR=$out/share/fcitx5/pinyin/dictionaries
    mkdir -p $DIR
    ${pkgs.libime}/bin/libime_pinyindict ${~/Gist/dicts/fcitx/main.txt} $DIR/main.dict
  '';
in {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = [
        pkgs.qt6Packages.fcitx5-chinese-addons
        pkgs.fcitx5-pinyin-zhwiki
        pkgs.fcitx5-mozc-ut
        pkgs.fcitx5-hangul
        my-dict
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
        Name="pinyin";
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
      Font=''"Sans Serif 16"'';
      MenuFont=''"Sans Serif 16"'';
      TrayFont=''"Sans Serif 16"'';
      Theme="default";
      DarkTheme="default-dark";
      # Follow system light/dark color scheme
      UseDarkTheme="True";
      # Follow system accent color if it is supported by theme and desktop
      UseAccentColor="True";
    };
    "conf/punctuation.conf" = (pkgs.formats.keyValue {}).generate "punctuation.conf" {
      # Half width punctuation after latin letter or number
      HalfWidthPuncAfterLetterOrNumber = "False";
    };
    # simplified/traditional chinese conversion
    "conf/chttrans.conf" = (pkgs.formats.ini {}).generate "chttrans.conf" {
      Hotkey."0" = "Alt+F";
    };
  };
  home.file.punc_mb_zh_CN = {
    source = pkgs.runCommand "punc.mb.zh_CN" {} /*bash*/ ''
      sed '/_ ——/d' ${pkgs.qt6Packages.fcitx5-chinese-addons}/share/fcitx5/punctuation/punc.mb.zh_CN > $out
      {
      cat <<APPEND
      < <
      > >
      ^ ^
      APPEND
      } >> $out
    '';
    target = ".local/share/fcitx5/punctuation/punc.mb.zh_CN";
  };

  dconf.settings = {
    # Disable ibus input method shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source=[];
      switch-input-source-backward=[];
    };
  };
}
