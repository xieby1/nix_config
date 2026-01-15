{ pkgs, ... }: {
  home.packages = [ pkgs.pkgsu.ironbar ];
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
        icon_size = 24;
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
  home.file.ironbar_style = {
    text = /*css*/ ''
      :root {
        --color-dark-primary: #1c1c1c;
        --color-dark-secondary: #2d2d2d;
        --color-active: #6699cc;
      }
      * {
        background-image: none;
        font-family: noto mono;
      }
      #bar, popover, popover contents, calendar {
        background-color: var(--color-dark-primary);
      }
      button {
        padding: 0;
      }
      button:hover, button:active {
        background-color: var(--color-dark-secondary);
      }
      #end > * + * {
        margin: 0.5em;
      }
      .clock {
        font-weight: bold;
      }
      .popup-clock .calendar-clock {
        font-size: 2.0em;
      }
      .popup-clock .calendar .today {
        background-color: var(--color-active);
      }
    '';
    target = ".config/ironbar/style.css";
  };
}
