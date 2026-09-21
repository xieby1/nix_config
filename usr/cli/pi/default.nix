{ config, pkgs, ... }:
let
  pi = pkgs.pkgsu.pi-coding-agent.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./retry-max-backoff-delay.patch ];
  });
in {
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    pi
  ];

  yq-merge.".pi/agent/settings.json".expr.retry = {
    enabled = true;
    maxRetries = 10;
    baseDelayMs = 1000;
    maxBackoffDelayMs = 10000;
  };

  home.file.".pi/agent/sessions".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/sessions;
}
