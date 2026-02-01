{ pkgs }: {
  "Mod+T".spawn = "kitty";
  "Ctrl+Alt+T".spawn = "kitty";
  "Mod+D".spawn-sh = "dms ipc call spotlight toggle";
  "Mod+W".spawn-sh = "rofi -show window -window-format '{c} {t}'";
  "Mod+L".spawn-sh = "dms ipc lock lock";
  "Mod+N".spawn-sh = "dms ipc notifications toggle";
  "Mod+X".spawn-sh = "dms ipc powermenu toggle";
  "Mod+V".spawn-sh = "dms ipc clipboard toggle";

  XF86AudioRaiseVolume = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
  };
  XF86AudioLowerVolume = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
  };
  XF86AudioMute = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  };
  XF86AudioMicMute = {
    _props.allow-when-locked = true;
    spawn-sh  = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
  };
  XF86AudioPlay = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.playerctl}/bin/playerctl play-pause";
  };
  XF86AudioStop = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.playerctl}/bin/playerctl stop";
  };
  XF86AudioPrev = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.playerctl}/bin/playerctl previous";
  };
  XF86AudioNext = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.playerctl}/bin/playerctl next";
  };
  XF86MonBrightnessUp = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set +10%";
  };
  XF86MonBrightnessDown = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set 10%-";
  };

  # Open/close the Overview: a zoomed-out view of workspaces and windows.
  # You can also move the mouse into the top-left hot corner,
  # or do a four-finger swipe up on a touchpad.
  "Mod" = {
    _props = { repeat = false; release = true; };
    toggle-overview = {};
  };

  "Alt+F4" = {
    _props.repeat = false;
    close-window = {};
  };

  "Mod+Left".move-column-left = {};
  "Mod+Right".move-column-right = {};
  "Mod+Up".maximize-column = {};
  "Mod+Down".set-column-width = "50%";

  "Ctrl+Alt+Left".focus-column-left = {};
  "Ctrl+Alt+Right".focus-column-right = {};

  "Mod+Home".focus-column-first = {};
  "Mod+End".focus-column-last = {};
  "Mod+Ctrl+Home".move-column-to-first = {};
  "Mod+Ctrl+End".move-column-to-last = {};

  "Mod+Shift+Left".focus-monitor-left = {};
  "Mod+Shift+Down".focus-monitor-down = {};
  "Mod+Shift+Up".focus-monitor-up = {};
  "Mod+Shift+Right".focus-monitor-right = {};

  "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = {};
  "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = {};
  "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = {};
  "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = {};

  "Mod+Page_Down".focus-workspace-down = {};
  "Mod+Page_Up".focus-workspace-up = {};
  "Mod+Ctrl+Page_Down".move-column-to-workspace-down = {};
  "Mod+Ctrl+Page_Up".move-column-to-workspace-up = {};

  "Mod+Shift+Page_Down".move-workspace-down = {};
  "Mod+Shift+Page_Up".move-workspace-up = {};

  "Mod+WheelScrollDown" = {
    _props.cooldown-ms = 150;
    focus-workspace-down = {};
  };
  "Mod+WheelScrollUp" = {
    _props.cooldown-ms = 150;
    focus-workspace-up = {};
  };
  "Mod+Ctrl+WheelScrollDown" = {
    _props.cooldown-ms = 150;
    move-column-to-workspace-down = {};
  };
  "Mod+Ctrl+WheelScrollUp" = {
    _props.cooldown-ms = 150;
    move-column-to-workspace-up = {};
  };

  "Mod+WheelScrollRight".focus-column-right = {};
  "Mod+WheelScrollLeft".focus-column-left = {};
  "Mod+Ctrl+WheelScrollRight".move-column-right = {};
  "Mod+Ctrl+WheelScrollLeft".move-column-left = {};

  "Mod+Shift+WheelScrollDown".focus-column-right = {};
  "Mod+Shift+WheelScrollUp".focus-column-left = {};
  "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = {};
  "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = {};

  "Mod+BracketLeft".consume-or-expel-window-left = {};
  "Mod+BracketRight".consume-or-expel-window-right = {};

  "Mod+Comma".consume-window-into-column = {};
  "Mod+Period".expel-window-from-column = {};

  "Mod+R".switch-preset-column-width = {};
  "Mod+Shift+R".switch-preset-window-height = {};
  "Mod+Ctrl+R".reset-window-height = {};
  "Mod+Shift+F".fullscreen-window = {};

  "Mod+Ctrl+F".expand-column-to-available-width = {};

  "Mod+C".center-column = {};
  "Mod+Ctrl+C".center-visible-columns = {};

  "Mod+Minus".set-column-width = "-25%";
  "Mod+Equal".set-column-width = "+25%";
  "Mod+Shift+Minus".set-window-height = "-25%";
  "Mod+Shift+Equal".set-window-height = "+25%";

  "Mod+F".toggle-window-floating = {};
  "Print".screenshot = {};
  "Ctrl+Print".screenshot-screen = {};
  "Alt+Print".screenshot-window = {};

  "Mod+Escape" = {
    _props.allow-inhibiting = false;
    toggle-keyboard-shortcuts-inhibit = {};
  };

  "Mod+Shift+E".quit = {};
  "Ctrl+Alt+Delete".quit = {};
  "Mod+Shift+P".power-off-monitors = {};
}
