{ pkgs, config, ... }: {
  imports = [ ./module.nix ];

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
  } // (let # my private calendars
    caldavs = "${config.home.homeDirectory}/Gist/Vault/caldavs.nix";
  in if builtins.pathExists caldavs then import caldavs else {});

  # Learn from <nixpkgs>/nixos/modules/services/desktops/gnome/evolution-data-server.nix
  home.packages = [ pkgs.evolutionWithPlugins ];
  dbus.packages = [ pkgs.evolutionWithPlugins ];
  systemd.user.services.evolution-source-dummy-deps = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit.Wants = [ "evolution-source-registry.service" "evolution-alarm-notify.service"];
    Service.ExecStart = "/usr/bin/env --version"; # dummy command
  };
}
