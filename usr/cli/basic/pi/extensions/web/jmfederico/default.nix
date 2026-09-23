{ config, pkgs, lib, ... }:
let
  inherit (config.home) homeDirectory;

  nodejs = pkgs.nodejs_22;

  # The pi CLI: PATH-only. jmfederico imports the *SDK* from node_modules (npm's
  # in-range 0.85.1), but shells out to `pi` for CLI/package operations.
  piPackage = pkgs.pkgsu.pi-coding-agent;

  # NOT ~/.pi-web: that is xing-shuyin's default and upstream's default too.
  dataDir = "${homeDirectory}/.local/state/pi-web";
  port = 8504;

  pi-web = pkgs.buildNpmPackage {
    pname = "pi-web";
    version = "1.202609.0";

    # Last release whose peer range (>=0.84.0 <0.85.0 || >=0.85.1) accepts pi 0.86.1.
    # v1.202609.1 tightened to >=0.87.0.
    src = pkgs.npinsed.ai.pi.pi-web-jmfederico;

    # Upstream's lock omits `integrity` for the 5 nested @earendil-works/* deps of
    # pi-coding-agent; prefetch-npm-deps panics on that. Add the fields.
    patches = [ ./lock-integrity.patch ];
    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-pMp+KK0yf3ua0q6Fzn5x8LD/x++0wECL8YWes3aMKrQ=";

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

  pathEnv = lib.makeBinPath [ piPackage nodejs pkgs.git ];
in
{
  home.packages = [ pi-web ];

  # Keep the daemon from mutating the (yq-merge-managed) ~/.pi/agent/settings.json:
  # at startup it auto-installs its shipped `@jmfederico/pi-relay` Pi package into the
  # active profile, writing a Nix-store path there. A dismissal entry disables that
  # for this profile; the package can still be installed by hand from Settings.
  home.file.".local/state/pi-web/pi-package-dismissals.json".text =
    ''{"dismissals":[{"profileDir":"${homeDirectory}/.pi/agent","packageId":"@jmfederico/pi-relay","dismissedAt":"1970-01-01T00:00:00.000Z"}]}'';

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
        "PATH=${pathEnv}"
      ];
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
        "PATH=${pathEnv}"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
