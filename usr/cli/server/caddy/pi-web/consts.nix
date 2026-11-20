# Shared by the Caddy route fragment (./caddy.nix) and the bridge service
# (./config.nix), which are generated from separate files but must agree on the
# port. Keeping them here stops the reverse_proxy upstream and the socat
# listener from drifting apart.
{
  # pi-web's own listening port; identical on every device.
  piWebPort = 8504;

  # aliyun-side loopback bridge -> dell:piWebPort, over the userspace-tailscale
  # SOCKS5 proxy. Caddy reverse_proxy targets this port.
  dellBridgePort = 9008;
}
