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

    # Filters are evaluated in filter_order; the first matching enabled filter wins:
    # https://docs.noctalia.dev/noctalia/v5.5.0/services/notifications/#filtering
    notification.filter_order = [ "calendar-lunar" "calendar" ];
    notification.filter.calendar-lunar = {
      match = "Calendar";
      # Match a lunar title in either a reminder summary or one line of an all-day digest body.
      match_content = "(^|\\n)[^ \\n]+ [^ \\n]+月 [0-9]{4}年(\\n|$)";
      # Calendar reminders are persistent by default; use the standard 6000 ms timeout for lunar ones.
      allow_permanent = false;
    };
    notification.filter.calendar = {
      match = "Calendar";
      override_duration = 0;
    };
  };
}
