{ pkgs, ... }: {
  home.packages = [ pkgs.ironbar ];
  home.file.ironbar_config = {
    text = builtins.toJSON {
      position = "top";
      autohide = 0;
      start = [{
        type = "launcher";
        favorites = [
          "firefox"
        ];
        # truncate = {
        #   mode = "end";
        #   max_length = 30;
        # };
      }];
      center = [{
        type = "clock";
        format = "%Y.%m.%d | %H:%M";
      }];
      end = [{
        type = "sys_info";
        format = [
          "⏲{cpu_percent:2}"
          "⛁{memory_percent:2.0}|{swap_percent:2.0}"
          "⇄{net_up#MB/s}|{net_down#MB/s}"
        ];
        interval.cpu = 1;
      }{
        type = "clipboard";
        max_items = 15;
      }{
        type = "volume";
      }{
        type = "tray";
      }{
        type = "battery";
        icon_size = 16;
        show_if = "[ -e /sys/class/power_supply/LCBT ]";
      }{
        type = "notifications";
      }];
    };
    target = ".config/ironbar/config.json";
  };
}
