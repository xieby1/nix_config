{ config, pkgs, stdenv, lib, ... }:
let
  tailscale-wrapper = {suffix, httpPort, socks5Port}: let
    tailscale-wrapped = pkgs.writeShellScriptBin "tailscale-${suffix}" ''
      tailscale --socket /tmp/tailscale-${suffix}.sock $@
    '';
    stateDir = "${config.home.homeDirectory}/.local/share/tailscale-${suffix}";
    tailscaled-wrapped = pkgs.writeShellScriptBin "tailscaled-${suffix}" ''
      TS_LOGS_DIR="${stateDir}" \
        ${pkgs.tailscale}/bin/tailscaled \
        --tun userspace-networking \
        --outbound-http-proxy-listen=localhost:${httpPort} \
        --socks5-server=localhost:${socks5Port} \
        --socket=/tmp/tailscale-${suffix}.sock \
        --state=${stateDir}/tailscaled.state \
        --statedir=${stateDir} \
        $@
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
  imports = [{
    home.packages = [pkgs.tailscale];
  }
    # (tailscale-wrapper {suffix="headscale"; httpPort="1055"; socks5Port="1065";})
    (tailscale-wrapper {suffix="official";  httpPort="1056"; socks5Port="1066";})
  ];
}
