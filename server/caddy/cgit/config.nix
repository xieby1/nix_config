{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  consts = import ./consts.nix;

  cacheRoot = "${config.xdg.cacheHome}/${consts.cacheDir}";
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.cgit pkgs.fcgiwrap ];

    # cgit writes its page-cache files directly into cache-root but never
    # creates that directory, so it must exist before the first request.
    home.activation.cgitCacheDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p $VERBOSE_ARG "${cacheRoot}"
    '';

    # cgit.cgi is plain CGI, which Caddy cannot run. fcgiwrap is the
    # FastCGI->CGI bridge: it stays up, accepts FastCGI from Caddy over
    # loopback and forks cgit.cgi (or git-http-backend) per request.
    # -c 4: one clone holds its slot for the whole transfer, and -c 1 would
    # queue everyone's browsing behind it.
    systemd.user.services.fcgiwrap-cgit = {
      Unit.Description = "fcgiwrap CGI bridge for cgit";
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = "${pkgs.fcgiwrap}/bin/fcgiwrap -c 4 -s tcp:127.0.0.1:${toString consts.fcgiwrapPort}";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
