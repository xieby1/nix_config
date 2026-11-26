{ lib, ... }: {
  imports = [
    ./event-titles
    ./china-calendar.nix
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

    notification.filter_order = [ "calendar" ];
    notification.filter.calendar = {
      match = "Calendar";
      override_duration = 0;
    };
  };
}
