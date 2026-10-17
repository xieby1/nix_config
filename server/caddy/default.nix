{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  consts = import ./cgit/consts.nix;

  # Bare repos, synced from the laptop by Syncthing; cgit's scan-path picks up
  # every repo under here automatically.
  cgitReposPath = "${config.home.homeDirectory}/Repos";
  cgitCacheRoot = "${config.xdg.cacheHome}/${consts.cacheDir}";

  # No spaces around '=': cgit's config reader keeps them in the key name
  # ("scan-path " != "scan-path"), silently ignoring the option.
  cgitrc = pkgs.writeText "cgitrc" ''
    # Served by Caddy at https://xieby1.cn${consts.prefix}/ ; see ./cgit/.
    virtual-root=${consts.prefix}/
    clone-prefix=https://xieby1.cn${consts.prefix}

    # Static assets are served by Caddy from the cgit package; see ./cgit/caddy.nix.
    css=${consts.prefix}/cgit.css
    favicon=${consts.prefix}/favicon.ico
    logo=${consts.prefix}/cgit.png
    js=${consts.prefix}/cgit.js

    # Clones go through git-http-backend on the Caddy side, not cgit's own
    # dumb-HTTP endpoint.
    enable-http-clone=0

    # cgit creates files directly under cache-root, so it must already exist;
    # ./cgit/config.nix creates it.
    cache-root=${cgitCacheRoot}
    scan-path=${cgitReposPath}
  '';

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

      # cgit routes; see ./cgit/.
      ${import ./cgit/caddy.nix {
        inherit (pkgs) cgit git;
        inherit cgitrc;
        reposPath = cgitReposPath;
      }}

      redir /web /web/
      handle /web/* {
        route {
          import auth
          uri strip_prefix /web
          root * ${config.home.homeDirectory}/web
          file_server
        }
      }

      reverse_proxy 127.0.0.1:9091
    }
  '';
in {
  imports = [
    ./pi-web/config.nix
    ./cgit/config.nix
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
