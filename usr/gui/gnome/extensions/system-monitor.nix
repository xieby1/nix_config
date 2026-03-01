#MC # system-monitor
{ pkgs, ... }: {
  home.packages = [
    # replace system-monitor(-next) with vitals
    # refers to https://github.com/mgalgs/gnome-shell-system-monitor-applet/issues/57
    # vitals
    pkgs.gnomeExtensions.system-monitor-next
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        # "Vitals@CoreCoding.com"
        "system-monitor-next@paradoxxx.zero.gmail.com"
      ];
    };
    # "org/gnome/shell/extensions/vitals" = {
    #   fixed-widths = true;
    #   hide-icons = true;
    #   hot-sensors = [
    #     "_processor_usage_"
    #     "_memory_usage_"
    #     "__network-rx_max__"
    #     "__network-tx_max__"
    #   ];
    #   show-fan = false;
    #   show-system = false;
    #   show-temperature = false;
    #   show-voltage = false;
    #   update-time = 2;
    # };
    "org/gnome/shell/extensions/system-monitor-next-applet" = {
      compact-display = true;
      icon-display = false;
      swap-display = true;
      cpu-style = "digit";
      memory-style = "digit";
      net-style = "digit";
      swap-style = "digit";
      cpu-show-text = false;
      memory-show-text = false;
      net-show-text = false;
      swap-show-text = false;
    };
  };
}
