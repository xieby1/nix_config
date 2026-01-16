{ pkgs, ... }: {
  imports = [
    ./ironbar.nix
    ./hyprshell.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      windowrule = "float, class:.*";
      animation = "global, 1, 3, default";
      exec-once = "ironbar";
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
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

        "Super, left, movewindowpixel, exact 0 0 ,activewindow"
        "Super, left, resizewindowpixel, exact 50% 100% ,activewindow"
        "Super, right, movewindowpixel, exact 50% 0 ,activewindow"
        "Super, right, resizewindowpixel, exact 50% 100% ,activewindow"
        # If use fullscreen then cannot see the ironbar
        # "Super, up, fullscreen, 1, set"
        # "Super, down, fullscreen, 1, unset"
        "Super, up, movewindowpixel, exact 0 0 ,activewindow"
        "Super, up, resizewindowpixel, exact 100% 100% ,activewindow"

        "Super, bracketleft, movewindowpixel, exact 0 0 ,activewindow"
        "Super, bracketleft, resizewindowpixel, exact 50% 50% ,activewindow"
        "Super, bracketright, movewindowpixel, exact 50% 0 ,activewindow"
        "Super, bracketright, resizewindowpixel, exact 50% 50% ,activewindow"
        "Super, comma, movewindowpixel, exact 0 50% ,activewindow"
        "Super, comma, resizewindowpixel, exact 50% 50% ,activewindow"
        "Super, period, movewindowpixel, exact 50% 50% ,activewindow"
        "Super, period, resizewindowpixel, exact 50% 50% ,activewindow"
        "Super, apostrophe, movewindowpixel, exact 0 0 ,activewindow"
        "Super, apostrophe, resizewindowpixel, exact 100% 50% ,activewindow"
        "Super, slash, movewindowpixel, exact 0 50% ,activewindow"
        "Super, slash, resizewindowpixel, exact 100% 50% ,activewindow"
        "Super, semicolon, movewindowpixel, exact 25% 25% ,activewindow"
        "Super, semicolon, resizewindowpixel, exact 50% 50% ,activewindow"

        ",XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 5%-"
        ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ",XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ];
    };
  };
}
