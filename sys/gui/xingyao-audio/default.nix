{ config, pkgs, lib, ... }: let
  initialize = pkgs.writeShellApplication {
    name = "xingyao-speakers";
    runtimeInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.alsa-tools ];
    text = builtins.readFile ./initialize.sh;
  };
in lib.mkIf (config.networking.hostName == "techrevo") {
  systemd.services.xingyao-speakers = {
    description = "Enable Xingyao 14 ALC256 second speaker path";
    enable = lib.mkDefault false;
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" "alsa-restore.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${initialize}/bin/xingyao-speakers on";
      ExecStop = "${initialize}/bin/xingyao-speakers off";
    };
  };
  # Keep the previous userspace workaround available as a fallback boot entry.
  specialisation.xingyao-speakers-workaround.configuration = {
    systemd.services.xingyao-speakers.enable = true;
  };
  boot.kernelPatches = lib.mkIf (!config.systemd.services.xingyao-speakers.enable) [{
    name = "alc256-xingyao-speakers";
    patch = ./alc256-xingyao-speakers.patch;
  }];
  powerManagement.resumeCommands = lib.mkIf config.systemd.services.xingyao-speakers.enable ''
    ${pkgs.systemd}/bin/systemctl restart xingyao-speakers.service
  '';
}
