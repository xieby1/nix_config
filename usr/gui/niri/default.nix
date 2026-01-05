{ config, pkgs, ... }: {
  home.packages = [
    pkgs.niri
  ];
  home.file.niri_config = {
    text = config.lib.generators.toKDL {} {
      input = {
        touchpad = {
          tap = {};
        };
      };
      layout = {
        gaps = 0;
        focus-ring.off = {};
        shadow = {
          on = {};
          spread = 2;
          offset._props = {x=2; y=2;};
        };
      };
      spawn-at-startup = "waybar";
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      binds = {
        "Mod+Shift+Slash".show-hotkey-overlay = {};
        "Mod+T" = {
          _props.hotkey-overlay-title = "Open a Terminal";
          spawn = "kitty";
        };
        "Mod+D" = {
          _props.hotkey-overlay-title = "Run an Application";
          spawn = "fuzzel";
        };
        "Super+Alt+L" = {
          _props.hotkey-overlay-title = "Lock the Screen: swaylock";
          spawn = "swaylock";
        };

        XF86AudioRaiseVolume = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
        };
        XF86AudioLowerVolume = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        };
        XF86AudioMute = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        XF86AudioMicMute = {
          _props.allow-when-locked = true;
          spawn-sh  = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };
        XF86AudioPlay = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl play-pause";
        };
        XF86AudioStop = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl stop";
        };
        XF86AudioPrev = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl previous";
        };
        XF86AudioNext = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl next";
        };
        XF86MonBrightnessUp = {
          _props.allow-when-locked = true;
          spawn = ["brightnessctl" "--class=backlight" "set" "+10%"];
        };
        XF86MonBrightnessDown = {
          _props.allow-when-locked = true;
          spawn = ["brightnessctl" "--class=backlight" "set" "10%-"];
        };

        # Open/close the Overview: a zoomed-out view of workspaces and windows.
        # You can also move the mouse into the top-left hot corner,
        # or do a four-finger swipe up on a touchpad.
        "Mod+O" = {
          _props.repeat = false;
          toggle-overview = {};
        };
        "Mod+Q" = {
          _props.repeat = false;
          close-window = {};
        };
        "Mod+Left".focus-column-left = {};
        "Mod+Down".focus-window-down = {};
        "Mod+Up".focus-window-up = {};
        "Mod+Right".focus-column-right = {};
        "Mod+H".focus-column-left = {};
        "Mod+J".focus-window-down = {};
        "Mod+K".focus-window-up = {};
        "Mod+L".focus-column-right = {};

        "Mod+Ctrl+Left".move-column-left = {};
        "Mod+Ctrl+Down".move-window-down = {};
        "Mod+Ctrl+Up".move-window-up = {};
        "Mod+Ctrl+Right".move-column-right = {};
        "Mod+Ctrl+H".move-column-left = {};
        "Mod+Ctrl+J".move-window-down = {};
        "Mod+Ctrl+K".move-window-up = {};
        "Mod+Ctrl+L".move-column-right = {};

        "Mod+Home".focus-column-first = {};
        "Mod+End".focus-column-last = {};
        "Mod+Ctrl+Home".move-column-to-first = {};
        "Mod+Ctrl+End".move-column-to-last = {};

        "Mod+Shift+Left".focus-monitor-left = {};
        "Mod+Shift+Down".focus-monitor-down = {};
        "Mod+Shift+Up".focus-monitor-up = {};
        "Mod+Shift+Right".focus-monitor-right = {};
        "Mod+Shift+H".focus-monitor-left = {};
        "Mod+Shift+J".focus-monitor-down = {};
        "Mod+Shift+K".focus-monitor-up = {};
        "Mod+Shift+L".focus-monitor-right = {};

        "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = {};
        "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = {};
        "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = {};
        "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = {};
        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = {};
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = {};
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = {};
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = {};

        "Mod+Page_Down".focus-workspace-down = {};
        "Mod+Page_Up".focus-workspace-up = {};
        "Mod+U".focus-workspace-down = {};
        "Mod+I".focus-workspace-up = {};
        "Mod+Ctrl+Page_Down".move-column-to-workspace-down = {};
        "Mod+Ctrl+Page_Up".move-column-to-workspace-up = {};
        "Mod+Ctrl+U".move-column-to-workspace-down = {};
        "Mod+Ctrl+I".move-column-to-workspace-up = {};

        "Mod+Shift+Page_Down".move-workspace-down = {};
        "Mod+Shift+Page_Up".move-workspace-up = {};
        "Mod+Shift+U".move-workspace-down = {};
        "Mod+Shift+I".move-workspace-up = {};

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

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;
        "Mod+Ctrl+1".move-column-to-workspace = 1;
        "Mod+Ctrl+2".move-column-to-workspace = 2;
        "Mod+Ctrl+3".move-column-to-workspace = 3;
        "Mod+Ctrl+4".move-column-to-workspace = 4;
        "Mod+Ctrl+5".move-column-to-workspace = 5;
        "Mod+Ctrl+6".move-column-to-workspace = 6;
        "Mod+Ctrl+7".move-column-to-workspace = 7;
        "Mod+Ctrl+8".move-column-to-workspace = 8;
        "Mod+Ctrl+9".move-column-to-workspace = 9;

        "Mod+BracketLeft".consume-or-expel-window-left = {};
        "Mod+BracketRight".consume-or-expel-window-right = {};

        "Mod+Comma".consume-window-into-column = {};
        "Mod+Period".expel-window-from-column = {};

        "Mod+R".switch-preset-column-width = {};
        "Mod+Shift+R".switch-preset-window-height = {};
        "Mod+Ctrl+R".reset-window-height = {};
        "Mod+F".maximize-column = {};
        "Mod+Shift+F".fullscreen-window = {};

        "Mod+Ctrl+F".expand-column-to-available-width = {};

        "Mod+C".center-column = {};
        "Mod+Ctrl+C".center-visible-columns = {};

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+V".toggle-window-floating = {};
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = {};
        "Mod+W".toggle-column-tabbed-display = {};
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
      };
    };
    target = ".config/niri/config.kdl";
  };
}
