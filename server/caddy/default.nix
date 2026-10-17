{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  consts = import ./cgit/consts.nix;

  # Bare repos, synced from the laptop by Syncthing; cgit's scan-path picks up
  # every repo under here automatically.
  cgitReposPath = "${config.home.homeDirectory}/Repos";
  cgitCacheRoot = "${config.xdg.cacheHome}/${consts.cacheDir}";

  # GitHub look, dark mode and a mobile layout, layered over cgit's own
  # stylesheet: https://www.hackitu.de/cgithub/ (AGPL-3.0). Pinned as a whole
  # tarball, so the theme can be swapped by bumping one hash; Caddy only ever
  # serves themeFile out of it. To bump: `nix store prefetch-file --unpack
  # --json <url>` (needs --extra-experimental-features nix-command; plain
  # nix-prefetch-url --unpack prints a base32 hash that Nix rejects as "invalid
  # SRI hash").
  cgitTheme = pkgs.fetchzip {
    name = "cgit-theme";
    url = "https://www.hackitu.de/cgithub/cgithub.tar.gz";
    hash = "sha256-bt7eZX7hFZ7vZfsBWGxN0Wdxkt6kFPbs//SxS5Gp8YM=";
  };

  # The served directory is built here so that a theme bump which renames the
  # stylesheet fails the switch instead of serving a 404 — browsers cache that
  # 404 for an hour (the cache header below), hiding the fix.
  cgitThemeRoot = pkgs.runCommandLocal "cgit-theme-root" { } ''
    cp -r ${cgitTheme}/. $out
    test -f $out${consts.themeFile}
  '';

  # The viewport tag is the load-bearing part: without it phones lay the page out
  # at 980px wide and the theme's media queries never fire.
  cgitHeadInclude = pkgs.writeText "cgit-head-include.html" ''
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <link rel="stylesheet" type="text/css" href="${consts.prefix}${consts.themeFile}"/>
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

    # Static assets are served by Caddy from the cgit package; see ./cgit/caddy.nix.
    css=${consts.prefix}/cgit.css
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

      # syncthing routes; see ./syncthing/.
      ${import ./syncthing/caddy.nix}

      # pi-web (dell) routes; see ./pi-web/.
      ${import ./pi-web/caddy.nix}

      # cgit routes; see ./cgit/.
      ${import ./cgit/caddy.nix {
        inherit (pkgs) cgit git;
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
