{ pkgs, lib, ... }: let
  amixer = "${pkgs.alsa-utils}/bin/amixer";
  initialize = pkgs.writeShellScript "xingyao-audio" ''
    set -eu
    ${amixer} -q -c Generic_1 sset Master 0dB unmute
    ${amixer} -q -c Generic_1 sset Speaker 0dB unmute
    ${amixer} -q -c Generic_1 sset Capture 0dB cap
  '';
  checkHardware = pkgs.writeShellScript "check-xingyao-audio" ''
    test "$(< /sys/class/dmi/id/board_name)" = "XINGYAO Series-P916F-STX" &&
      ${pkgs.gnugrep}/bin/grep -q '^Vendor Id: 0x10ec0256$' /proc/asound/Generic_1/codec#0 &&
      ${pkgs.gnugrep}/bin/grep -q '^Subsystem Id: 0x1d05e004$' /proc/asound/Generic_1/codec#0
  '';
in lib.mkIf (lib.trim (builtins.readFile /etc/hostname) == "techrevo") {
  # This model's UCM profile selects the unusable ACP-PDM capture path.
  xdg.configFile."wireplumber/wireplumber.conf.d/51-xingyao-audio.conf".text = builtins.toJSON {
    "monitor.alsa.rules" = [{
      matches = [{ "device.name" = "alsa_card.pci-0000_c1_00.6"; }];
      actions.update-props."api.alsa.use-acp" = false;
    } {
      matches = [{ "node.name" = "alsa_output.pci-0000_c1_00.6.playback.0.0"; }];
      # Raw four-channel playback leaves the shared speaker DAC on silent channels 3/4.
      actions.update-props = {
        "audio.channels" = 2;
        "audio.position" = [ "FL" "FR" ];
      };
    }];
  };

  # With ACP disabled, hardware switches must be initialized separately.
  systemd.user.services.xingyao-audio = {
    Unit = {
      Description = "Initialize Xingyao 14 ALC256 capture and speakers";
      After = [ "wireplumber.service" ];
      PartOf = [ "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecCondition = "${checkHardware}";
      ExecStart = "${initialize}";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "wireplumber.service" ];
  };
}
