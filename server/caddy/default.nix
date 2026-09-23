{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;

  # dell's pi-web (jmfederico) listens only on its own loopback. aliyun reaches
  # the tailnet through its userspace tailscaled SOCKS5 proxy; socat turns that proxy
  # into a plain loopback upstream Caddy can reverse_proxy to.
  dellIp = config.my.tailscale.devices.dell.ip;
  tailscaleSocksPort = config.my.tailscale.instances.official.socks5Port;
  dellPiWebPort = 8504;
  piWebBridgePort = 9008;
  caddyfile = pkgs.writeText "Caddyfile" ''
    (auth) {
      forward_auth 127.0.0.1:9091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
    }

    https://xieby1.cn {
      redir /sixu/xby /sixu/xby/
      redir /sixu/wxy /sixu/wxy/
      redir /circle/xby /circle/xby/
      redir /circle/wxy /circle/wxy/
      redir /syncthing /syncthing/
      redir /pi/dell /pi/dell/

      handle /sixu/xby/* {
        route {
          import auth
          uri strip_prefix /sixu/xby
          reverse_proxy 127.0.0.1:3000
        }
      }
      handle /sixu/wxy/* {
        route {
          import auth
          uri strip_prefix /sixu/wxy
          reverse_proxy 127.0.0.1:3001
        }
      }
      handle /circle/xby/* {
        route {
          import auth
          uri strip_prefix /circle/xby
          reverse_proxy 127.0.0.1:3002
        }
      }
      handle /circle/wxy/* {
        route {
          import auth
          uri strip_prefix /circle/wxy
          reverse_proxy 127.0.0.1:3003
        }
      }

      handle /syncthing/* {
        route {
          import auth
          uri strip_prefix /syncthing
          reverse_proxy 127.0.0.1:8384 {
            header_up Host {upstream_hostport}
          }
        }
      }

      # dell's pi-web (jmfederico) over the tailnet via the socat bridge.
      # pi-web is prefix-portable, so only this sub-path needs routing; it keeps
      # its browser/PWA/WS URLs under /pi/dell/ itself.
      handle /pi/dell/* {
        route {
          import auth
          uri strip_prefix /pi/dell
          reverse_proxy 127.0.0.1:${toString piWebBridgePort}
        }
      }

      redir /web /web/
      handle /web/* {
        route {
          import auth
          uri strip_prefix /web
          root * ${config.home.homeDirectory}/Web
          file_server
        }
      }

      reverse_proxy 127.0.0.1:9091
    }
  '';
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.caddy pkgs.socat ];

    # Loopback TCP -> aliyun's userspace-tailscale SOCKS5 -> dell pi-web.
    systemd.user.services.pi-web-bridge-dell = {
      Unit = {
        Description = "SOCKS bridge: Caddy -> dell pi-web over userspace tailscale";
        After = [ "tailscaled-official.service" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString piWebBridgePort},bind=127.0.0.1,fork,reuseaddr SOCKS5-CONNECT:127.0.0.1:${toString tailscaleSocksPort}:${dellIp}:${toString dellPiWebPort}";
        Restart = "on-failure";
        RestartSec = 3;
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
