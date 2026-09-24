{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  caddyfile = pkgs.writeText "Caddyfile" ''
    (auth) {
      forward_auth 127.0.0.1:9091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
    }

    https://xieby1.cn {
      # sixu routes; see ./sixu/.
      ${import ./sixu/caddy.nix}

      # circle routes; see ./circle/.
      ${import ./circle/caddy.nix}

      # syncthing routes; see ./syncthing/.
      ${import ./syncthing/caddy.nix}

      # pi-web (dell) routes; see ./pi-web/.
      ${import ./pi-web/caddy.nix}

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
  imports = [
    ./pi-web/config.nix
  ];

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
