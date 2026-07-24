{ config, lib, pkgs, ... }:
let
  # tailscaled-official runs in userspace networking mode. Its HTTP CONNECT
  # proxy reaches remote tailnet peers, but CONNECT to this node's own 100.x IP
  # hangs instead of hairpinning back to the host network stack where local sshd
  # listens. Check the runtime Tailscale IPs and use 127.0.0.1 for self; keep
  # HTTP CONNECT for real remote peers.
  #
  # Do not detect self by comparing `tso.<name>` with `/etc/hostname`: Tailscale
  # aliases can intentionally differ from machine hostnames.
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
