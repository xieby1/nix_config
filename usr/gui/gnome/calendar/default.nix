{ config, ... }: {
  imports = [
    ./module.nix
    { # my private calendars
      gnome-calendar = let
        caldavs = "${config.home.homeDirectory}/Gist/Vault/caldavs.nix";
      in if builtins.pathExists caldavs then import caldavs else {};
    }
  ];

  # public calendars
  gnome-calendar = {
    china_calendar = {
      # 包含所有类型日历（暂时除农历、天干地支）(时间段版本)
      url = "https://yangh9.github.io/ChinaCalendar/calendar_1.ics";
      settings = {
        Calendar = {
          Color = "#82B366";
        };
        # do not show notifications for this calendar
        Alarms = {
          IncludeMe = false;
          ForEveryEvent = false;
        };
      };
    };
  };
}
