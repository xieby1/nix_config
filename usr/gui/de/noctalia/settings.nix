{ lib, ... }: {
  yq-merge.".config/noctalia/settings.toml" = {
    generator = lib.generators.toINI {
      mkKeyValue = key: value: "${key} = ${builtins.toJSON value}";
    };
    expr = {
      "bar.default" = {
        smart_auto_hide = true;
        auto_hide_reserve_space = true;
        margin_ends = 0;
        start = [ "notifications" "wallpaper" "media" "workspaces" "active_window" ];
        center = [ "clock" "weather" ];
        end = [ "tray" "cpu" "ram" "swap" "network_tx" "network_rx" "battery" "control-center" ];
      };
      location.address = "shenzhen";
      "widget.media" = {
        hide_when_no_media = true;
        show_progress = true;
      };
      "widget.cpu" = {
        show_glyph = false;
        visualization = "none";
      };
      "widget.ram" = {
        visualization = "none";
        show_glyph = false;
      };
      "widget.swap" = {
        type = "sysmon";
        stat = "swap_pct";
        visualization = "none";
        show_glyph = false;
      };
      "widget.network_tx" = {
        label_min_width = 36;
        network_speed_compact = true;
        visualization = "none";
      };
      "widget.network_rx" = {
        label_min_width = 36;
        network_speed_compact = true;
        visualization = "none";
      };
    };
  };
}
