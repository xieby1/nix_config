{ config, lib, pkgs, ... }:
let
  # `tso.*` aliases normally go through tailscaled-official's userspace HTTP
  # proxy, but proxying this node's own 100.x IP hangs before SSH sees a banner.
  # Do the self check by comparing `%h` with `tailscale-official ip -4` at SSH
  # runtime. Do not compare the `tso.<name>` key with `/etc/hostname`: the
  # Tailscale alias can intentionally differ from the machine hostname.
  tailscaleOfficialSshProxy = pkgs.writeShellScriptBin "tailscale-official-ssh-proxy" ''
    set -u

    host="$1"
    port="$2"
    self_ips="$(${pkgs.coreutils}/bin/timeout 2s ${pkgs.tailscale}/bin/tailscale --socket /tmp/tailscale-official.sock ip -4 2>/dev/null || true)"

    for ip in $self_ips; do
      if [ "$host" = "$ip" ]; then
        exec ${pkgs.netcat}/bin/nc 127.0.0.1 "$port"
      fi
    done

    exec ${pkgs.netcat}/bin/nc -X connect -x 127.0.0.1:${toString config.my.tailscale.instances.official.httpPort} "$host" "$port"
  '';
in {
  home.packages = [
    tailscaleOfficialSshProxy
  ];

  programs.ssh.matchBlocks = lib.mapAttrs' (name: value: lib.nameValuePair
    "tso.${name}" {
      hostname = value.ip;
      user = value.user;
      serverAliveInterval = 60;
      proxyCommand = "${tailscaleOfficialSshProxy}/bin/tailscale-official-ssh-proxy %h %p";
    }
  ) config.my.tailscale.devices;
}
