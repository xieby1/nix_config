{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  repoDir = "${config.home.homeDirectory}/.config/nixpkgs";
  autheliaConfig = "${repoDir}/server/authelia/configuration.yml";
  caddyfile = "${repoDir}/server/Caddyfile";
in {
  options.my.server.caddyAuthelia.enable = lib.mkEnableOption "Caddy + Authelia prototype user services";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.authelia
      pkgs.caddy
    ];

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

    systemd.user.services.caddy-auth-proxy = {
      Unit = {
        Description = "Caddy auth proxy";
        After = [ "authelia.service" ];
        Wants = [ "authelia.service" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = "${pkgs.caddy}/bin/caddy run --config ${caddyfile} --adapter caddyfile";
        ExecReload = "${pkgs.caddy}/bin/caddy reload --config ${caddyfile} --adapter caddyfile --force";
        Restart = "on-failure";
      };
    };
  };
}
