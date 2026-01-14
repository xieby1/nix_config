{ ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = "ironbar";
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
      };
      decoration = {
        rounding = 10;
        rounding_power = 2;
      };
      input = {
        follow_mouse = 2;
      };
      gestures = {
        workspace_swipe_invert = false;
      };
      gesture = "3, horizontal, workspace";
      "$mainMod" = "SUPER";
      bind = [
        "Ctrl+Alt, T, exec, kitty"
        "Alt, F4, killactive,"
        "Super, M, exit,"
        "Super, D, exec, rofi -show drun"
        "Ctrl+Alt, left, workspace, -1"
        "Ctrl+Alt, right, workspace, +1"
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };
}
