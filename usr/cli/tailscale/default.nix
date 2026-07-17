# VPS firewall/security-group ports for the official Tailscale instance:
# - UDP 41641: normal Tailscale peer-to-peer/direct traffic (--port below).
# - UDP 40000: peer relay traffic (--relay-server-port set after startup).
{ ... }: {
  imports = [
    ./module/instances.nix
    ./devices.nix
  ];

  my.tailscale.instances.official = {
    httpPort = 1056;
    socks5Port = 1066;
    relayServerPort = 40000;
  };
}
