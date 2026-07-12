{ lib, ... }:
{
  imports = [
    ./authelia
    ./caddy
  ];

  options.my.server.caddyAuthelia.enable = lib.mkEnableOption "Caddy + Authelia prototype user services";
}
