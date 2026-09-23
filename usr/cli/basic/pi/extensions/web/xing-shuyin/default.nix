{ config, pkgs, lib, ... }:
let
  inherit (config.home) homeDirectory;

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

    # node_modules ships katex's font-generation *.py scripts and node-pty's
    # build/config.gypi, which drag python3 (~200 MiB) into the runtime closure.
    # None of them run at runtime, so strip the references.
    nativeBuildInputs = [ pkgs.removeReferencesTo ];
    postInstall = ''
      find $out -type f -not -name '*.node' -print0 \
        | xargs -0 -r remove-references-to -t "${pkgs.python3}"

      # react-icons (~85 MiB) is only used to build the frontend, which upstream
      # ships prebuilt in web/dist/. Nothing in the runtime code (bin/, dist/)
      # imports it, but it is misdeclared as a runtime dependency.
      rm -rf $out/lib/node_modules/pi-web-ui/node_modules/react-icons

      find $out -xtype l -delete
    '';
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
      # No PATH override: inherit the systemd user manager's PATH (50-systemd-path.conf),
      # which already has ~/.nix-profile/bin (pi, node, git). Overriding it stripped
      # coreutils/eza from the embedded terminal, breaking ~/.zshrc at startup.
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
