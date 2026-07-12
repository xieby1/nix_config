{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  caddyfile = pkgs.writeText "Caddyfile" ''
    {
      auto_https disable_redirects
      skip_install_trust
    }

    https://127.0.0.1:8443 {
      tls internal

      redir /app /app/

      handle /app/* {
        route {
          forward_auth 127.0.0.1:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
          }

          uri strip_prefix /app
          reverse_proxy 127.0.0.1:3000
        }
      }

      reverse_proxy 127.0.0.1:9091
    }
  '';
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.caddy ];

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
