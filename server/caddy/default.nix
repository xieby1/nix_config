{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  caddyfile = pkgs.writeText "Caddyfile" ''
    https://xieby1.cn {
      redir /sixu/xby /sixu/xby/
      redir /sixu/wxy /sixu/wxy/
      redir /syncthing /syncthing/

      handle /sixu/xby/* {
        route {
          forward_auth 127.0.0.1:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
          }

          uri strip_prefix /sixu/xby
          reverse_proxy 127.0.0.1:3000
        }
      }
      handle /sixu/wxy/* {
        route {
          forward_auth 127.0.0.1:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
          }

          uri strip_prefix /sixu/wxy
          reverse_proxy 127.0.0.1:3001
        }
      }
      handle /syncthing/* {
        route {
          forward_auth 127.0.0.1:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
          }

          uri strip_prefix /syncthing
          reverse_proxy 127.0.0.1:8384 {
            header_up Host {upstream_hostport}
          }
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
