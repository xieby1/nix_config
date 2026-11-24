# We want to edit the remote ICS files before feed them to Noctalia.
# So we need to fetch ICS files by ourselves,
# that is why we utilize systemd timer.
{ lib, pkgs, config, ... }:
let
  feeds = [ "cal_holiday_1" "cal_solarTerm" "cal_lunar" ];
  calendarDir = "${config.home.homeDirectory}/.local/share/calendars";
  fetchCalendars = pkgs.writeShellScript "noctalia-calendar-ics" ''
    failed=0
    for feed in ${lib.concatStringsSep " " feeds}; do
      (
        dir="${calendarDir}/$feed"
        ${pkgs.coreutils}/bin/mkdir -p "$dir"
        raw=$(${pkgs.coreutils}/bin/mktemp "$dir/.raw.XXXXXX.tmp")
        out=$(${pkgs.coreutils}/bin/mktemp "$dir/.calendar.XXXXXX.tmp")
        trap '${pkgs.coreutils}/bin/rm -f "$raw" "$out"' EXIT

        ${pkgs.curl}/bin/curl --fail --location --silent --show-error \
          --connect-timeout 10 --max-time 60 --retry 2 \
          -o "$raw" "https://yangh9.github.io/ChinaCalendar/$feed.ics" || exit 1
        ${pkgs.gnugrep}/bin/grep -q '^BEGIN:VCALENDAR' "$raw" &&
          ${pkgs.gnugrep}/bin/grep -q '^BEGIN:VEVENT' "$raw" &&
          ${pkgs.gnugrep}/bin/grep -q '^END:VCALENDAR' "$raw" || exit 1
        ${pkgs.gnused}/bin/sed -e '/^SUMMARY[:;]/s/[「」『』]//g' \
          -e 's/^\(SUMMARY:\)\([^ ]*月\) \([^ ]*\)/\1\3 \2/' "$raw" > "$out" || exit 1
        ${pkgs.coreutils}/bin/mv -f "$out" "$dir/calendar.ics"
      ) || failed=1
    done
    exit "$failed"
  '';
in {
  systemd.user.services.noctalia-calendar-ics = {
    Unit.Description = "Fetch and edit ChinaCalendar ICS feeds";
    Service = {
      Type = "oneshot";
      ExecStart = fetchCalendars;
    };
  };
  systemd.user.timers.noctalia-calendar-ics = {
    Unit.Description = "Refresh ChinaCalendar ICS feeds hourly";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
  programs.noctalia.settings.calendar.account = {
    cal_holiday_1 = {
      type = "vdir";
      color = "#B85450";
      name = "法定节假日";
      path = "${calendarDir}/cal_holiday_1";
    };
    cal_solarTerm = {
      type = "vdir";
      color = "#82B366";
      name = "二十四节气";
      path = "${calendarDir}/cal_solarTerm";
    };
    cal_lunar = {
      type = "vdir";
      color = "#666666";
      name = "农历、天干地支";
      path = "${calendarDir}/cal_lunar";
    };
  };
}
