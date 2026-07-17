# VPS firewall/security-group ports for the official Tailscale instance:
# - UDP 41641: normal Tailscale peer-to-peer/direct traffic (--port below).
# - UDP 40000: peer relay traffic (--relay-server-port set after startup).
{ config, pkgs, lib, ... }:
let
  tailscale-wrapper = {suffix, httpPort, socks5Port}: let
    tailscale-wrapped = pkgs.writeShellScriptBin "tailscale-${suffix}" ''
      ${pkgs.tailscale}/bin/tailscale --socket /tmp/tailscale-${suffix}.sock $@
    '';
    stateDir = "${config.home.homeDirectory}/.local/share/tailscale-${suffix}";
    tailscaled-wrapped = pkgs.writeShellScriptBin "tailscaled-${suffix}" ''
      TS_LOGS_DIR="${stateDir}" \
        ${pkgs.tailscale}/bin/tailscaled \
        --port=41641 \
        --tun userspace-networking \
        --outbound-http-proxy-listen=localhost:${httpPort} \
        --socks5-server=localhost:${socks5Port} \
        --socket=/tmp/tailscale-${suffix}.sock \
        --state=${stateDir}/tailscaled.state \
        --statedir=${stateDir} \
        $@
    '';
    relayServerPort = "40000";
    setRelayServerPort = pkgs.writeShellScript "tailscale-${suffix}-set-relay-server-port" ''
      i=0
      while [ "$i" -lt 20 ]; do
        if ${tailscale-wrapped}/bin/tailscale-${suffix} set --relay-server-port=${relayServerPort}; then
          exit 0
        fi
        i=$((i + 1))
        ${pkgs.coreutils}/bin/sleep 0.5
      done
      exit 1
    '';
  in {
    home.packages = [
      tailscale-wrapped
      tailscaled-wrapped
    ];
    systemd.user.services."tailscaled-${suffix}" = {
      Unit = {
        Description = "Auto start tailscaled-${suffix} userspace network";
        After = ["clash.service"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        Environment = [
          "HTTPS_PROXY=http://127.0.0.1:${toString config.proxyPort}"
          "HTTP_PROXY=http://127.0.0.1:${toString config.proxyPort}"
          "https_proxy=http://127.0.0.1:${toString config.proxyPort}"
          "http_proxy=http://127.0.0.1:${toString config.proxyPort}"
        ];
        ExecStart = "${tailscaled-wrapped}/bin/tailscaled-${suffix}";
        # The relay server port is a tailscale preference, not a tailscaled flag.
        # ExecStartPost can race the daemon socket on startup, so retry briefly.
        ExecStartPost = "${setRelayServerPort}";
      };
    };
    programs.zsh.initContent = ''
      compdef _tailscale tailscale-${suffix}
    '' + lib.optionalString config.isNixOnDroid ''
      # start tailscale-${suffix}
      if [[ -z "$(pidof tailscaled-${suffix})" ]]; then
          tmux new -d -s tailscaled-${suffix} tailscaled-${suffix}
      fi
    '';
  };
in {
  imports = [
    { home.packages = [pkgs.tailscale]; }
    (tailscale-wrapper {suffix="official";  httpPort="1056"; socks5Port="1066";})
  ];
}
