{ config, pkgs, lib, ... }:
let
  cfg = config.my.tailscale.instances;

  mkInstance = suffix: instance:
    let
      stateDir = "${config.home.homeDirectory}/.local/share/tailscale-${suffix}";
      relayServerPort = toString instance.relayServerPort;
      tailscale-wrapped = pkgs.writeShellScriptBin "tailscale-${suffix}" ''
        ${pkgs.tailscale}/bin/tailscale --socket /tmp/tailscale-${suffix}.sock $@
      '';
      tailscaled-wrapped = pkgs.writeShellScriptBin "tailscaled-${suffix}" ''
        TS_LOGS_DIR="${stateDir}" \
          ${pkgs.tailscale}/bin/tailscaled \
          --port=41641 \
          --tun userspace-networking \
          --outbound-http-proxy-listen=localhost:${toString instance.httpPort} \
          --socks5-server=localhost:${toString instance.socks5Port} \
          --socket=/tmp/tailscale-${suffix}.sock \
          --state=${stateDir}/tailscaled.state \
          --statedir=${stateDir} \
          $@
      '';
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
      packages = [
        tailscale-wrapped
        tailscaled-wrapped
      ];
      service = {
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
      zshInit = ''
        compdef _tailscale tailscale-${suffix}
      '' + lib.optionalString config.isNixOnDroid ''
        # start tailscale-${suffix}
        if [[ -z "$(pidof tailscaled-${suffix})" ]]; then
            tmux new -d -s tailscaled-${suffix} tailscaled-${suffix}
        fi
      '';
    };

  instanceNames = lib.attrNames cfg;
  instances = map (name: {
    inherit name;
    value = mkInstance name cfg.${name};
  }) instanceNames;
in {
  options.my.tailscale.instances = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        httpPort = lib.mkOption {
          type = lib.types.port;
          default = 1056;
        };
        socks5Port = lib.mkOption {
          type = lib.types.port;
          default = 1066;
        };
        relayServerPort = lib.mkOption {
          type = lib.types.port;
          default = 40000;
        };
      };
    });
    default = {};
  };

  config = {
    home.packages = lib.mkIf (instanceNames != []) (
      [ pkgs.tailscale ] ++ lib.concatMap (instance: instance.value.packages) instances
    );

    systemd.user.services = lib.mkMerge (map (instance: {
      "tailscaled-${instance.name}" = instance.value.service;
    }) instances);

    programs.zsh.initContent = lib.concatStringsSep "" (map (instance: instance.value.zshInit) instances);
  };
}
