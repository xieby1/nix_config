{ pkgs, ... }: {
  home.packages = with pkgs.gnomeExtensions; [
    lunar-calendar
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "lunarcal@ailin.nemui"
      ];
    };
    "org/gnome/shell/extensions/lunar-calendar" = {
      # 日历内的节日
      jrrilinei = true;
      # 顶栏日期
      show-date = true;
      # 顶栏时间
      show-time = false;
      # 语言：大陆
      yuyan = 0;
    };
  };
}
