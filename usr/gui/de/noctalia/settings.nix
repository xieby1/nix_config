{ lib, ... }: {
  # Noctalia loads every TOML file here alphabetically, so yq-merge's
  # staging file would override the intended settings.toml.
  home.file.".config/noctalia/settings.toml".text =
    lib.generators.toINI {
      mkKeyValue = key: value: "${key} = ${builtins.toJSON value}";
    } {
      "bar.default" = {
        radius = 0;
        smart_auto_hide = true;
        auto_hide_reserve_space = true;
        margin_ends = 0;
        start = [
          "notifications" "daily-wallpaper"
          "media"
          "taskbar"
        ];
        center = [
          "active_window"
          "clock_sep_left"
          "clock"
          "clock_sep_right"
          "weather"
        ];
        end = [
          "tray"
          "cpu" "ram" "ram_pct" "swap_pct" "disk_used" "disk_used_pct"
          "network_tx" "network_rx"
          "output_volume"
          "bluetooth"
          "network"
          "battery"
          "control-center"
        ];
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
          "nzlov/daily-wallpaper"
        ];
      };
      "widget.daily-wallpaper" = {
        type = "nzlov/daily-wallpaper:widget";
        show_text = false;
      };
      "widget.taskbar" = {
        group_by_workspace = true;
        hide_empty_workspaces = true;
        show_workspace_label = false;
        workspace_group_inactive_border_color = "shadow";
      };

      "widget.clock_sep_left" = {
        type = "text";
        color = "primary";
        text = "|";
      };
      "widget.clock" = {
        format = "{:%Y.%m.%d %a %H:%M}";
        anchor = true;
      };
      "widget.clock_sep_right" = {
        type = "text";
        color = "primary";
        text = "|";
      };
      "widget.weather" = {
        show_condition = false;
      };

      "widget.media" = {
        hide_when_no_media = true;
        show_progress = true;
        # max_length = 160;
        # min_length = 160;
        # title_scroll = "on_hover";
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
      "widget.disk_used" = {
        type = "sysmon";
        stat = "disk_used";
        visualization = "none";
        show_glyph = false;
      };
      "widget.disk_used_pct" = {
        type = "sysmon";
        stat = "disk_used_pct";
        visualization = "none";
        show_glyph = false;
      };
      "widget.network_tx" = {
        label_min_width = 40;
        network_speed_compact = true;
        network_speed_unit = "mb";
        visualization = "none";
      };
      "widget.network_rx" = {
        label_min_width = 40;
        network_speed_compact = true;
        network_speed_unit = "mb";
        visualization = "none";
      };
      "widget.network" = {
        show_label = false;
      };
      "widget.output_volume" = {
        show_label = false;
      };

      shell = {
        clipboard_auto_paste = "off";
        clipboard_history_max_entries = 10000;
      };

      "idle.behavior.lock" = {
        action = "lock";
        enabled = true;
        timeout = 600;
      };
      "idle.behavior.screen-off" = {
        action = "screen_off";
        enabled = true;
        timeout = 660;
      };
      "idle.behavior.lock-and-suspend" = {
        action = "lock_and_suspend";
        enabled = false;
      };
      "osd.kinds" = {
        keyboard_layout = false;
      };

      "shell.launcher" = {
        default_view = "all";
      };

      calendar = {
        enabled = true;
        event_date_format = "%B %e %A";
      };
      "calendar.account.outlook" = {
        type = "ics";
        name = "xieby1 Outlook";
        server_url = lib.trim (builtins.readFile ~/Gist/Vault/calendars/outlook.txt);
      };
      "calendar.account.outlook_kxh" = {
        type = "ics";
        color = "on_tertiary";
        name = "KXH Outlook";
        server_url = lib.trim (builtins.readFile ~/Gist/Vault/calendars/outlook_kxh.txt);
      };
      "calendar.account.cal_holiday_1" = {
        type = "ics";
        color = "#B85450";
        name = "法定节假日";
        server_url = "https://yangh9.github.io/ChinaCalendar/cal_holiday_1.ics";
      };
      "calendar.account.cal_solarTerm" = {
        type = "ics";
        color = "#82B366";
        name = "二十四节气";
        server_url = "https://yangh9.github.io/ChinaCalendar/cal_solarTerm.ics";
      };
      "calendar.account.cal_lunar" = {
        type = "ics";
        color = "#666666";
        name = "农历、天干地支";
        server_url = "https://yangh9.github.io/ChinaCalendar/cal_lunar.ics";
      };

      control_center = {
        width = 1200;
      };
    };
}
