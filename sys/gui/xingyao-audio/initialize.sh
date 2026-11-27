#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in on|off) ;; *) echo 'Usage: xingyao-speakers on|off' >&2; exit 2;; esac

[[ "$(< /sys/class/dmi/id/board_name)" == 'XINGYAO Series-P916F-STX' ]]
codec="$(readlink -f /proc/asound/Generic_1)/codec#0"
grep -qx 'Vendor Id: 0x10ec0256' "$codec"
grep -qx 'Subsystem Id: 0x1d05e004' "$codec"
[[ "$codec" =~ /card([0-9]+)/codec#([0-9]+)$ ]]
device="/dev/snd/hwC${BASH_REMATCH[1]}D${BASH_REMATCH[2]}"
power="/sys/bus/hdaudio/devices/hdaudioC${BASH_REMATCH[1]}D${BASH_REMATCH[2]}/power/control"
pin_state() {
  awk '/^Node 0x1b / {p=1} p && /^Node / && !/^Node 0x1b / {exit} p {print}' "$codec"
}
pin=$(pin_state)
grep -Fq '0x02* 0x03' <<< "$pin"
grep -Fq 'EAPD 0x2: EAPD' <<< "$pin"

# Restore this machine's verified original pin and runtime-power policy.
restore() {
  local status=0
  hda-verb "$device" 0x1b SET_AMP_GAIN_MUTE 0xb080 || status=1
  hda-verb "$device" 0x1b SET_PIN_WIDGET_CONTROL 0x20 || status=1
  printf 'auto\n' > "$power" || status=1
  return "$status"
}
if [[ "$1" == off ]]; then
  restore
  exit
fi
trap 'status=$?; trap - ERR; restore; exit "$status"' ERR
# Codec runtime resume overwrites raw verbs; leave other devices' power saving alone.
printf 'on\n' > "$power"
hda-verb "$device" 0x1b SET_PIN_WIDGET_CONTROL 0x40
hda-verb "$device" 0x1b SET_AMP_GAIN_MUTE 0xb000
pin=$(pin_state)
grep -Fq 'Pin-ctls: 0x40: OUT' <<< "$pin"
grep -Fq 'Amp-Out vals:  [0x00 0x00]' <<< "$pin"
trap - ERR
