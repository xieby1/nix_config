{ lib, ... }: {
  imports = [
    ./event-titles
  ];
  programs.noctalia.settings = {
    calendar = {
      enabled = true;
      event_date_format = "%B %e %A";
    };
    calendar.reminders = {
      default_lead_minutes = 3; # min
      all_day_digest_time = "08:00";
    };
    calendar.account.outlook = {
      type = "ics";
      name = "xieby1 Outlook";
      server_url = lib.trim (builtins.readFile ~/Gist/Vault/calendars/outlook.txt);
    };
    calendar.account.outlook_kxh = {
      type = "ics";
      color = "on_tertiary";
      name = "KXH Outlook";
      server_url = lib.trim (builtins.readFile ~/Gist/Vault/calendars/outlook_kxh.txt);
    };
    calendar.account.cal_holiday_1 = {
      type = "ics";
      color = "#B85450";
      name = "法定节假日";
      server_url = "https://yangh9.github.io/ChinaCalendar/cal_holiday_1.ics";
    };
    calendar.account.cal_solarTerm = {
      type = "ics";
      color = "#82B366";
      name = "二十四节气";
      server_url = "https://yangh9.github.io/ChinaCalendar/cal_solarTerm.ics";
    };
    calendar.account.cal_lunar = {
      type = "ics";
      color = "#666666";
      name = "农历、天干地支";
      server_url = "https://yangh9.github.io/ChinaCalendar/cal_lunar.ics";
    };
  };
}
