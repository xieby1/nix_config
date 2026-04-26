{ pkgs, config, ... }: {
  systemd.user.services.low-battery-notify = {
    Service = {
      Type = "oneshot";
      # https://unix.stackexchange.com/questions/60778/how-can-i-get-an-alert-when-my-battery-is-about-to-die-in-linux-mint
      ExecStart = pkgs.writeShellScript "low-battery-notify.sh" ''
        STATE_FILE="${config.home.homeDirectory}/.local/state/low-battery-notified"
        mkdir -p "$(dirname "$STATE_FILE")"

        battery_level=$(${pkgs.acpi}/bin/acpi -b | grep -P -o '[0-9]+(?=%)' | head -1)
        if [ -z "$battery_level" ]; then
          exit 0
        fi

        if [ "$battery_level" -le 20 ]; then
          if [ ! -f "$STATE_FILE" ]; then
            ${pkgs.libnotify}/bin/notify-send "⚠️Battery low" "🔋Battery level is $battery_level%!"
            touch "$STATE_FILE"
          fi
        else
          if [ -f "$STATE_FILE" ]; then
            rm -f "$STATE_FILE"
          fi
        fi
      '';
    };
  };

  systemd.user.timers.low-battery-notify = {
    Timer = {
      # The syntax of OnCalendar: `man systemd.time`
      OnCalendar = "*:0/10"; # every 10 minutes
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
