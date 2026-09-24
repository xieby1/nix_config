{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  consts = import ./consts.nix;

  # dell's pi-web (jmfederico) listens only on its own loopback. aliyun reaches
  # the tailnet through its userspace tailscaled SOCKS5 proxy; socat turns that proxy
  # into a plain loopback upstream Caddy can reverse_proxy to.
  dellIp = config.my.tailscale.devices.dell.ip;
  tailscaleSocksPort = config.my.tailscale.instances.official.socks5Port;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.socat ];

    # Loopback TCP -> aliyun's userspace-tailscale SOCKS5 -> dell pi-web.
    systemd.user.services.pi-web-bridge-dell = {
      Unit = {
        Description = "SOCKS bridge: Caddy -> dell pi-web over userspace tailscale";
        After = [ "tailscaled-official.service" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString consts.bridgePort},bind=127.0.0.1,fork,reuseaddr SOCKS5-CONNECT:127.0.0.1:${toString tailscaleSocksPort}:${dellIp}:${toString consts.dellPort}";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
