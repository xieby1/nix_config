{ config, ... }: {
  systemd.user.services.daily-work-reminder = {
    Unit = {
      Description = "Daily AI work reminder notification";
      ConditionPathExists = "${config.home.homeDirectory}/Gist/script/bash/daily-work-reminder.sh";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/Gist/script/bash/daily-work-reminder.sh";
      TimeoutStartSec = 300;
    };
  };

  systemd.user.timers.daily-work-reminder = {
    Unit = {
      Description = "Run daily AI work reminder at 08:00";
      ConditionPathExists = "${config.home.homeDirectory}/Gist/script/bash/daily-work-reminder.sh";
    };

    Timer = {
      OnCalendar = "Mon..Fri 08:00";
      Persistent = true;
    };

    Install.WantedBy = [ "timers.target" ];
  };
}
