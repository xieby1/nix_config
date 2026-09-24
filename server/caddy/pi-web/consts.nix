# Shared by the Caddy route fragment (./caddy.nix) and the bridge service
# (./config.nix), which are generated from separate files but must agree on the
# port. Keeping them here stops the reverse_proxy upstream and the socat
# listener from drifting apart.
{
  # Loopback port the socat bridge listens on; Caddy reverse_proxy targets it.
  bridgePort = 9008;

  # pi-web's own loopback port on dell; the socat bridge connects to it through
  # the tailnet SOCKS5 proxy.
  dellPort = 8504;
}
