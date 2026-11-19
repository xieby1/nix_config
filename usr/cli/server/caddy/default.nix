{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  consts = import ./cgit/consts.nix;

  # Bare repos, synced from the laptop by Syncthing; cgit's scan-path picks up
  # every repo under here automatically.
  cgitReposPath = "${config.home.homeDirectory}/Repos";
  cgitCacheRoot = "${config.xdg.cacheHome}/${consts.cacheDir}";

  # Mobile-friendly cgit stylesheet, pinned to a Git revision.
  cgitTheme = ((import <npins> {input=./cgit/sources.json;}).responsive-cgit-css {inherit pkgs;}).outPath;

  # Fail the build if the pinned theme no longer provides its stylesheet.
  cgitThemeRoot = pkgs.runCommandLocal "cgit-theme-root" { } ''
    install -Dm644 ${cgitTheme}/cgit.css $out${consts.themeFile}
  '';

  cgit = import ./cgit/package.nix { inherit pkgs; };

  # The viewport tag lets the theme's mobile media queries use device width.
  cgitHeadInclude = pkgs.writeText "cgit-head-include.html" ''
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
  '';

  # No spaces around '=': cgit's config reader keeps them in the key name
  # ("scan-path " != "scan-path"), silently ignoring the option.
  cgitrc = pkgs.writeText "cgitrc" ''
    # Served by Caddy at https://xieby1.cn${consts.prefix}/ ; see ./cgit/.
    virtual-root=${consts.prefix}/
    # HTTPS clone needs git-compatible auth in front of it, so advertise the
    # SSH URL people actually clone with (same form as npins/my/sources.json).
    # $CGIT_REPO_URL is the repo path relative to scan-path.
    clone-url=ssh://root@xieby1.cn/~/Repos/$CGIT_REPO_URL

    # Caddy serves the pinned responsive stylesheet; cgit's other assets
    # still come from the cgit package (see ./cgit/caddy.nix).
    css=${consts.prefix}${consts.themeFile}
    head-include=${cgitHeadInclude}
    favicon=${consts.prefix}/favicon.ico
    logo=${consts.prefix}/cgit.png
    js=${consts.prefix}/cgit.js

    # Clones go through git-http-backend on the Caddy side, not cgit's own
    # dumb-HTTP endpoint.
    enable-http-clone=0

    # cgit creates files directly under cache-root, so it must already exist;
    # ./cgit/config.nix creates it.
    cache-root=${cgitCacheRoot}
    # cgit hardcodes the footer timestamp to UTC (+0000); local-time makes it use
    # the server timezone (Asia/Shanghai here).
    # shortcut: local-time is global, so commit/tag/atom dates also render as
    # +0800 instead of the author's tz; patch cgit's footer if per-view tz matters.
    local-time=1
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
      # Nothing here pre-compresses; the stylesheet and cgit's HTML are plain text.
      encode zstd gzip

      # sixu routes; see ./sixu/.
      ${import ./sixu/caddy.nix}

      # circle routes; see ./circle/.
      ${import ./circle/caddy.nix}

      # XingYao authenticates before stripping its public prefix.
      ${import ./xingyao/caddy.nix}

      # syncthing routes; see ./syncthing/.
      ${import ./syncthing/caddy.nix}

      # pi-web (dell) routes; see ./pi-web/.
      ${import ./pi-web/caddy.nix}

      # cgit routes; see ./cgit/.
      ${import ./cgit/caddy.nix {
        inherit cgit;
        inherit (pkgs) git;
        inherit cgitrc;
        themeRoot = cgitThemeRoot;
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
    ./cgit/ssh
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
