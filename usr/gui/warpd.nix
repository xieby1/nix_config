{ pkgs, lib, ... }: {
  home.packages = [ pkgs.warpd ];
  home.file.autostart_warpd = {
    target = ".config/autostart/warpd.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=warpd
      Exec=${pkgs.warpd}/bin/warpd
    '';
  };

  # 为什么不用gnome快捷键？
  # * 一次性warpd启动比warpd后台运行慢
  # 为什么用gnome快捷键
  # * warpd没办法正确识别M-k键？或者是gnome抢了？要M-kk才行
  # dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
  #   "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/warpd-hint/"
  #   "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/warpd-normal/"
  # ];
  # dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/warpd-hint" = {
  #   binding="<Super>k";
  #   command = "warpd --hint";
  #   name="warpd-hint";
  # };
  # dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/warpd-normal" = {
  #   binding="<Alt>k";
  #   command = "warpd --normal";
  #   name="warpd-normal";
  # };
  home.file.warpd_config = {
    target = ".config/warpd/config";
    # Available options see `warpd --list-options`.
    # Available modifiers (according to warpd source code):
    # * alt: A-
    # * super/meta: M-
    # * shift: S-
    # * ctrl: C-
    # Available X11 key names by removing "XK_" prefix in ${pkgs.xorg.xorgproto}/include/X11/keysymdef.h
    text = lib.generators.toKeyValue {mkKeyValue=lib.generators.mkKeyValueDefault {} ": ";} {
      activation_key = "A-M-z"; # 一只手按A-M-z比A-M-c更方便！
      buttons = "q w e";
      left  = "Left";
      up    = "Up";
      right = "Right";
      down  = "Down";
      scroll_up   = "S-Up";
      scroll_down = "S-Down";
    };
  };
}
