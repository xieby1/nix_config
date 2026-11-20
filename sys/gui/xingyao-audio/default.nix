{ config, pkgs, lib, ... }: let
  initialize = pkgs.writeShellApplication {
    name = "xingyao-speakers";
    runtimeInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.alsa-tools ];
    text = builtins.readFile ./initialize.sh;
  };
in lib.mkIf (config.networking.hostName == "techrevo") {
  systemd.services.xingyao-speakers = {
    description = "Enable Xingyao 14 ALC256 second speaker path";
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" "alsa-restore.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${initialize}/bin/xingyao-speakers on";
      ExecStop = "${initialize}/bin/xingyao-speakers off";
    };
  };
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart xingyao-speakers.service
  '';
}
