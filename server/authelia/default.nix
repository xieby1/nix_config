{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  repoDir = "${config.home.homeDirectory}/.config/nixpkgs";
  autheliaConfig = "${repoDir}/server/authelia/configuration.yml";
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.authelia ];

    systemd.user.services.authelia = {
      Unit = {
        Description = "Authelia authentication portal";
        After = [ "network.target" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        WorkingDirectory = repoDir;
        EnvironmentFile = ~/Gist/Vault/server/authelia.env;
        ExecStart = "${pkgs.authelia}/bin/authelia --config ${autheliaConfig}";
        Restart = "on-failure";
      };
    };
  };
}
