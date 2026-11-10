{ enableExtendedCLI }:
{ config, lib, ... }:
let
  npinsed = import <npins> {input=./sources.json;};
  pipkgs = import ./pkgs.nix {src = npinsed.nixpkgs;};
in {
  imports = [
    (lib.modules.importApply ./extensions {
      inherit enableExtendedCLI pipkgs;
      sources = {
        inherit (npinsed)
          acp pi-hermes-memory shelken-pi-extensions pi-math
          pi-language-tutor pi-retry pi-context-view pi-model-project
          pi-skill-usage pi-heuristic-notify pi-web-access pi-title rpiv-mono;
      };
    })
    ./providers
  ] ++ lib.optionals enableExtendedCLI [
    (lib.modules.importApply ./pi-web {src = npinsed.pi-web;})
  ];
  home.packages = [
    # Include session-file size (S5.5M) in Pi's built-in footer stats line.
    (pipkgs.pi-coding-agent.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./footer-session-size.patch ];
    }))
  ];

  yq-merge.".pi/agent/settings.json" = {
    generator = builtins.toJSON;
    expr = {
      retry = {
        enabled = true;
        maxRetries = 10;
        baseDelayMs = 1000;
        maxAgentDelayMs = 10000;
      };
      # pi >=1.0 defaults to "fullscreen", where Pi redraws the transcript viewport on
      # every scroll; "regular" lets terminal scroll its own (fast) scrollback buffer.
      tuiMode = "regular";
    };
  };

  home.file.".pi/agent/sessions".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/sessions;
}
