{ lib, ... }: {
  # Noctalia loads every TOML file here alphabetically, so yq-merge's
  # staging file would override the intended settings.toml.
  home.file.".config/noctalia/settings.toml".text =
    lib.generators.toINI {
      mkKeyValue = key: value: "${key} = ${builtins.toJSON value}";
    } {
      "bar.default" = {
        smart_auto_hide = true;
        auto_hide_reserve_space = true;
        margin_ends = 0;
        start = [ "notifications" "daily-wallpaper" "media" "stack" "active_window" ];
        center = [ "clock" "weather" ];
        end = [ "tray" "cpu" "ram" "ram_pct" "swap_pct" "network_tx" "network_rx" "battery" "control-center" ];
      };
      location.address = "shenzhen";
      # Noctalia 5.4.1 has no config-only setting for the server default timeout.
      # An unspecified timeout (-1) becomes a hardcoded 6,000 ms before filtering,
      # so this catch-all filter also overrides sender-requested timeouts.
      "notification.filter.persistent" = {
        match_content = ".*";
        override_duration = 0;
      };

      plugins = {
        enabled = [
          "johnnyp0t/niri-workspace-stack"
          "nzlov/daily-wallpaper"
        ];
      };
      "widget.daily-wallpaper" = {
        type = "nzlov/daily-wallpaper:widget";
      };
      "widget.stack" = {
        type = "johnnyp0t/niri-workspace-stack:stack";
        displayMode = "numbered_rail";
        show_numbers = false;
      };

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
      "widget.ram_pct" = {
        type = "sysmon";
        stat = "ram_pct";
        visualization = "none";
        show_glyph = false;
      };
      "widget.swap_pct" = {
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
}
