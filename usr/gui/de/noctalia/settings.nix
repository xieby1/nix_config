{ ... }: {
  imports = [
    ./calendar
  ];
  programs.noctalia.settings = {
    bar.default = {
      radius = 0;
      smart_auto_hide = true;
      auto_hide_reserve_space = true;
      margin_ends = 0;
      start = [
        "notifications"
        "taskbar"
      ];
      center = [
        # "active_window"
        "clock_date"
        "clock_time"
        "clock_weekday"
        "weather"
      ];
      end = [
        "media"
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
    notification.filter.persistent = {
      match_content = ".*";
      override_duration = 0;
    };

    widget.taskbar = {
      group_by_workspace = true;
      hide_empty_workspaces = true;
      show_workspace_label = false;
      workspace_group_inactive_border_color = "shadow";
    };

    widget.clock_date = {
      type = "clock";
      format = "{:%Y.%m.%d}";
    };
    widget.clock_time = {
      type = "clock";
      format = "{:%H:%M}";
      anchor = true;
      font_weight = 700;
    };
    widget.clock_weekday = {
      type = "clock";
      format = "{:%a}";
    };
    widget.weather = {
      show_condition = false;
    };

    widget.media = {
      album_art_only = true;
      rotate_album_art = true;
      hide_when_no_media = true;
      actions = {
        left = "media toggle";
        right = "panel-toggle control-center media";
      };
    };
    widget.cpu = {
      show_glyph = false;
      visualization = "none";
    };
    widget.ram = {
      visualization = "none";
      show_glyph = false;
    };
    widget.ram_pct = {
      type = "sysmon";
      stat = "ram_pct";
      visualization = "none";
      show_glyph = false;
    };
    widget.swap_pct = {
      type = "sysmon";
      stat = "swap_pct";
      visualization = "none";
      show_glyph = false;
    };
    widget.disk_used = {
      type = "sysmon";
      stat = "disk_used";
      visualization = "none";
      show_glyph = false;
    };
    widget.disk_used_pct = {
      type = "sysmon";
      stat = "disk_used_pct";
      visualization = "none";
      show_glyph = false;
    };
    widget.network_tx = {
      label_min_width = 32;
      network_speed_compact = true;
      network_speed_unit = "mb";
      visualization = "none";
      show_glyph = false;
    };
    widget.network_rx = {
      label_min_width = 32;
      network_speed_compact = true;
      network_speed_unit = "mb";
      visualization = "none";
      show_glyph = false;
    };
    widget.network = {
      show_label = false;
    };
    widget.output_volume = {
      show_label = false;
    };
    widget.battery = {
      display_mode = "graphic";
    };

    shell = {
      clipboard_auto_paste = "off";
      clipboard_history_max_entries = 10000;
    };

    idle.behavior.lock = {
      action = "lock";
      enabled = true;
      timeout = 600;
    };
    idle.behavior.screen-off = {
      action = "screen_off";
      enabled = true;
      timeout = 660;
    };
    idle.behavior.lock-and-suspend = {
      action = "lock_and_suspend";
      enabled = false;
    };
    osd.kinds = {
      keyboard_layout = false;
    };

    shell.launcher = {
      default_view = "all";
    };

    control_center = {
      width = 1200;
      shortcuts = [
        {type = "wifi";}
        {type = "bluetooth";}
        {type = "dark_mode";}
        {type = "session";}
      ];
    };
  };
}
