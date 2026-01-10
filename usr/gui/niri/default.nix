# 不足：niri还不支持viewport的查询和控制！
{ config, pkgs, ... }: let
  niri = pkgs.niri.overrideAttrs (final: prev: {
    # Implement release keybinds and modifier-only binds
    # https://github.com/YaLTeR/niri/pull/2456/commits
    # src = pkgs.fetchFromGitHub {
    #   owner = "flowerysong";
    #   repo = "niri";
    #   rev = "86edeb3b0b3d1a08d4d4f59705cbc99a732f5e95";
    #   hash = "sha256-VFOGkBKA03fIXf/BaXsN6CZqkwUTq1gPvTIGrEMmlTQ=";
    # };
    src = pkgs.fetchFromGitHub {
      owner = "flowerysong";
      repo = "niri";
      rev = "53447431c4adcfe1572fed5f39ebddc239ca381c";
      hash = "sha256-onL4kGGpNHYNIaU11hN440RruSJKcTblSi7CwqMbYeM=";
    };
    # https://nixos.wiki/wiki/Rust#Using_overrideArgs_with_Rust_Packages
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = final.src;
      hash = "sha256-bh3NrnlFz2m8aCCakgpblFrswh02ByJVPVgxBbTZ6ts=";
    };
    # Unnecessary due to cargoDeps having higher priority than cargoHash,
    # but to make it explicitly that cargoHash is not used after overrideAttrs.
    cargoHash = null;
  });
in {
  home.packages = [
    niri
  ];
  home.file.niri_config = {
    text = config.lib.generators.toKDL {} {
      output = {
        _args = ["eDP-1"];
        scale = 2.0;
      };
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
      gestures.hot-corners.off = {};
      overview.zoom = 0.25;
    };
    target = ".config/niri/config.kdl";
  };
}
