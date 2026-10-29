{ config, pkgs, lib, ... }:
let
  inherit (config.home) homeDirectory;

  nodejs = pkgs.nodejs_22;

  # NOT ~/.pi-web: that is xing-shuyin's default and upstream's default too.
  dataDir = "${homeDirectory}/.local/state/pi-web";
  port = 8504;

  pi-web = pkgs.buildNpmPackage {
    pname = "pi-web";
    version = "1.202610.8";

    src = pkgs.npinsed.ai.pi.pi-web;

    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-G5+9zWy5yE3ETPIGg5ADoLWJ/Zc1jTRVTo6crqGH0mM=";

    inherit nodejs;
    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/pi-web $out/bin
      cp -r dist node_modules package.json $out/lib/node_modules/pi-web/
      # npm workspace symlinks point into the relocated build tree; drop dangling ones.
      find $out/lib/node_modules/pi-web/node_modules -type l ! -exec test -e {} \; -delete 2>/dev/null || true
      makeWrapper ${nodejs}/bin/node $out/bin/pi-web          --add-flags "$out/lib/node_modules/pi-web/dist/cli.js"
      makeWrapper ${nodejs}/bin/node $out/bin/pi-web-server   --add-flags "$out/lib/node_modules/pi-web/dist/server/index.js"
      makeWrapper ${nodejs}/bin/node $out/bin/pi-web-sessiond --add-flags "$out/lib/node_modules/pi-web/dist/server/sessiond.js"
      runHook postInstall
    '';
  };

in
{
  home.packages = [ pi-web ];

  # Prevent pi-web from auto-installing packages into the managed Pi settings.
  home.file.".local/state/pi-web/pi-package-dismissals.json".text = builtins.toJSON {
    dismissals = map (packageId: {
      profileDir = "${homeDirectory}/.pi/agent";
      inherit packageId;
      dismissedAt = "1970-01-01T00:00:00.000Z";
    }) [ "@jmfederico/pi-relay" "@jmfederico/pi-web-workflows" ];
  };

  # Web/API restarts do not interrupt in-flight work; the daemon owns the runtimes.
  systemd.user.services.pi-web-sessiond = {
    Unit = {
      Description = "pi-web session daemon (owns Pi session runtimes)";
      After = [ "network.target" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pi-web}/bin/pi-web-sessiond";
      Environment = [
        "PI_WEB_DATA_DIR=${dataDir}"
      ];
      # No PATH override: inherit the manager PATH (50-systemd-path.conf) so the
      # embedded terminal gets ~/.nix-profile/bin (pi, node, git, coreutils...).
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.user.services.pi-web-web = {
    Unit = {
      Description = "pi-web web/API server";
      After = [ "pi-web-sessiond.service" ];
      Requires = [ "pi-web-sessiond.service" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pi-web}/bin/pi-web-server";
      Environment = [
        "PI_WEB_PORT=${toString port}"
        "PI_WEB_DATA_DIR=${dataDir}"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
