{ enableExtendedCLI }:
{ config, lib, pkgs, ... }:
let
  npinsed = import <npins> {input=./sources.json;};
  pipkgs = import ./pkgs.nix {src = npinsed.nixpkgs;};
in {
  imports = [
    (lib.modules.importApply ./extensions {
      inherit enableExtendedCLI pipkgs;
      sources = npinsed;
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
    # The settings merge retains removed keys; drop the retired extension's namespace on activation.
    postOnChange = ''
      run ${pkgs.yq-go}/bin/yq -i 'del(.piRetry)' "$HOME/.pi/agent/settings.json"
    '';
    expr = {
      # Native retry uses one lifecycle-owned scheduler; gateway classifications are patched in pkgs.nix.
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
