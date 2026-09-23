{ config, pkgs, lib, ... }:
let
  inherit (config.home) homeDirectory;

  piPackage = pkgs.pkgsu.pi-coding-agent;
  dataDir = "${homeDirectory}/.pi-web";
  port = 8787;

  pi-web-ui = pkgs.buildNpmPackage {
    pname = "pi-web-ui";
    version = "0.94.1";

    # Bundles its own pi SDK; the lockfile pins 0.85.1 (same as jmfederico's).
    src = pkgs.npinsed.ai.pi.pi-web-ui-xing-shuyin;

    # Same 5 missing `integrity` fields as jmfederico's lock.
    patches = [ ./lock-integrity.patch ];
    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-KRNKlSG09ry6xaQ51WGM0J0sf2DHdqk/J6QgkkRTfR4=";

    nodejs = pkgs.nodejs_22;
  };
in
{
  home.packages = [ pi-web-ui ];

  systemd.user.services.pi-web-ui = {
    Unit = {
      Description = "pi-web-ui browser cockpit";
      After = [ "network.target" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pi-web-ui}/bin/pi-web-ui --port ${toString port} --host 127.0.0.1 --agent-dir ${homeDirectory}/.pi/agent --data-dir ${dataDir} --no-browser";
      WorkingDirectory = homeDirectory;
      Environment = [
        "PATH=${lib.makeBinPath [ piPackage pkgs.nodejs_22 pkgs.git ]}"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
