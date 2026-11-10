# Use `wev` to find out key name
{ pkgs }: {
  "Ctrl+Alt+T".spawn = "ghostty";
  "Mod+D".spawn-sh = "dms ipc call spotlight toggle";
  "Mod+W".spawn-sh = "rofi -show window -window-format '{c} {t}'";
  "Mod+Alt+L".spawn-sh = "dms ipc lock lock";
  "Mod+N".spawn-sh = "dms ipc notifications toggle";
  "Mod+X".spawn-sh = "dms ipc powermenu toggle";
  "Mod+V".spawn-sh = "dms ipc clipboard toggle";
  "Mod+H".spawn-sh = "dms ipc bar toggleAutoHide name 'Main Bar'";
  "Mod+F".spawn-sh = "ghostty -e bash -i fzf-doc";
  "Mod+S".spawn-sh = "${pkgs.wl-kbptr}/bin/wl-kbptr -o modes=floating,click -o mode_floating.source=detect";

  XF86AudioRaiseVolume = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
  };
  XF86AudioLowerVolume = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
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
    spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set +5%";
  };
  XF86MonBrightnessDown = {
    _props.allow-when-locked = true;
    spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set 5%-";
  };

  # Open/close the Overview: a zoomed-out view of workspaces and windows.
  # You can also move the mouse into the top-left hot corner,
  # or do a four-finger swipe up on a touchpad.
  # "Mod" = {
  #   _props = { repeat = false; release = true; };
  #   toggle-overview = {};
  # };
  "Mod+O".toggle-overview = {};
  "Mod+Z".animate-window = {};

  "Alt+F4" = {
    _props.repeat = false;
    close-window = {};
  };
  "Mod+BackSpace" = {
    _props.repeat = false;
    close-window = {};
  };

  "Mod+T".toggle-column-tabbed-display = {};

  "Mod+Left".focus-column-left = {};
  "Mod+Right".focus-column-right = {};
  "Mod+Up".focus-window-up = {};
  "Mod+Down".focus-window-down = {};

  "Ctrl+Mod+Left".move-column-left = {};
  "Ctrl+Mod+Right".move-column-right = {};
  "Ctrl+Mod+Up".move-window-up = {};
  "Ctrl+Mod+Down".move-window-down = {};

  "Ctrl+Alt+Left".focus-monitor-left = {};
  "Ctrl+Alt+Right".focus-monitor-right = {};
  "Ctrl+Alt+Up".focus-workspace-up = {};
  "Ctrl+Alt+Down".focus-workspace-down = {};

  "Mod+Home".focus-column-first = {};
  "Mod+End".focus-column-last = {};
  "Mod+Ctrl+Home".move-column-to-first = {};
  "Mod+Ctrl+End".move-column-to-last = {};

  "Shift+Mod+Left".move-column-to-monitor-left = {};
  "Shift+Mod+Right".move-column-to-monitor-right = {};
  "Shift+Mod+Up".move-column-to-workspace-up = {};
  "Shift+Mod+Down".move-column-to-workspace-down = {};

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

  # TODO: move to ../../win_align.nix
  "Mod+Semicolon".align-column-left = {};
  "Mod+Apostrophe".align-column-right = {};

  "Mod+R".switch-preset-column-width = {};
  "Mod+Shift+R".switch-preset-window-height = {};
  "Mod+Ctrl+R".reset-window-height = {};
  "Mod+Shift+F".fullscreen-window = {};
  "Mod+Alt+F".fullscreen-window = {};

  "Mod+Ctrl+F".expand-column-to-available-width = {};

  "Mod+C".center-column = {};
  "Mod+Ctrl+C".center-visible-columns = {};

  "Mod+Minus".set-column-width = "50%";
  "Mod+Equal".set-column-width = "100%";
  "Mod+Shift+Minus".set-column-width = "-25%";
  "Mod+Shift+Equal".set-column-width = "+25%";
  "Mod+0".set-window-height = "+25%";
  "Mod+9".set-window-height = "-25%";

  "Mod+Backslash".toggle-window-floating = {};
  "Print".screenshot = {};
  "Mod+P".screenshot = {};
  "Ctrl+Print".screenshot-screen = {};
  "Ctrl+Mod+P".screenshot-screen = {};
  "Alt+Print".screenshot-window = {};
  "Alt+Mod+P".screenshot-window = {};

  "Mod+Escape" = {
    _props.allow-inhibiting = false;
    toggle-keyboard-shortcuts-inhibit = {};
  };

  "Mod+Shift+E".quit = {};
  "Ctrl+Alt+Delete".quit = {};
} // (let
  # Inspired by: https://github.com/niri-wm/niri/discussions/2769
  move-column-to-new-workspace-ARG = arg: pkgs.writeShellScript "move-column-to-new-workspace" ''
    idx=$(niri msg --json workspaces \
      | ${pkgs.yq-go}/bin/yq '.[] | select (.is_focused) | .idx')
    niri msg action move-column-to-workspace 1
    niri msg action move-workspace-to-index $((idx${arg}))
  '';
  move-column-to-new-workspace-up = move-column-to-new-workspace-ARG "";
  move-column-to-new-workspace-down = move-column-to-new-workspace-ARG "+1";
  new-empty-workspace = delta: pkgs.writeShellScript "new-empty-workspace" ''
    set -euo pipefail
    exec {lock}>"$XDG_RUNTIME_DIR/niri-empty-workspace.lock"
    ${pkgs.util-linux}/bin/flock "$lock"
    ws=$(niri msg -j workspaces)
    idx=$(printf '%s\n' "$ws" | ${pkgs.yq-go}/bin/yq -r '.[] | select(.is_focused) | .idx')
    output=$(printf '%s\n' "$ws" | ${pkgs.yq-go}/bin/yq -r '.[] | select(.is_focused) | .output')
    last=$(printf '%s\n' "$ws" | ${pkgs.yq-go}/bin/yq -r \
      '(.[] | select(.is_focused) | .output) as $monitor | .[] | select(.output == $monitor) | .idx' \
      | sort -n | tail -1)
    [[ "$idx" =~ ^[0-9]+$ && "$last" =~ ^[0-9]+$ && -n "$output" ]]
    name="__niri-empty-$$"
    niri msg action set-workspace-name "$name" --workspace "$last"
    prior_name=""
    cleanup() {
      if [[ -n "$prior_name" && "$prior_name" != null ]]; then
        niri msg action set-workspace-name "$prior_name" --workspace "$name"
      else
        niri msg action unset-workspace-name "$name"
      fi
    }
    trap cleanup EXIT
    named=$(niri msg -j workspaces)
    named_output=$(printf '%s\n' "$named" | NIRI_WS_NAME="$name" ${pkgs.yq-go}/bin/yq -r '.[] | select(.name == strenv(NIRI_WS_NAME)) | .output')
    named_id=$(printf '%s\n' "$named" | NIRI_WS_NAME="$name" ${pkgs.yq-go}/bin/yq -r '.[] | select(.name == strenv(NIRI_WS_NAME)) | .id')
    [[ "$named_id" =~ ^[0-9]+$ ]]
    prior_name=$(printf '%s\n' "$ws" | NIRI_WS_ID="$named_id" ${pkgs.yq-go}/bin/yq -r '.[] | select(.id == env(NIRI_WS_ID)) | .name')
    [[ "$named_output" == "$output" ]]
    occupied=$(niri msg -j windows | ${pkgs.yq-go}/bin/yq -r ".[] | select(.workspace_id == $named_id) | .id")
    [[ -z "$occupied" ]]
    niri msg action move-workspace-to-index "$((idx + ${toString delta}))" --reference "$name"
    niri msg action focus-workspace "$name"
    cleanup
    trap - EXIT
  '';
in {
  "Ctrl+Shift+Mod+Up".spawn = toString move-column-to-new-workspace-up;
  "Ctrl+Shift+Mod+Down".spawn = toString move-column-to-new-workspace-down;

  "Ctrl+Shift+Alt+Up" = {
    _props.repeat = false;
    spawn = toString (new-empty-workspace 0);
  };
  "Ctrl+Shift+Alt+Down" = {
    _props.repeat = false;
    spawn = toString (new-empty-workspace 1);
  };
})
