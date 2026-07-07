{ pkgs, ... }:
let
  pkgspi = (pkgs.flake-compat {src = pkgs.npinsed.ai.pi.llm-agents;})
    .defaultNix.packages.${pkgs.stdenv.system};
  pi = pkgspi.pi.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./retry-max-backoff-delay.patch ];
  });
in {
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    # TODO: using pi in pkgsu?
    pi
  ];

  yq-merge.".pi/agent/settings.json".expr.retry = {
    enabled = true;
    maxRetries = 6;
    baseDelayMs = 1000;
    maxBackoffDelayMs = 10000;
  };
}
