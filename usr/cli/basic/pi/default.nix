{ config, pkgs, ... }:
{
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    pkgs.pkgsu.pi-coding-agent
  ];

  yq-merge.".pi/agent/settings.json".expr.retry = {
    enabled = true;
    maxRetries = 10;
    baseDelayMs = 1000;
    maxAgentDelayMs = 10000;
  };

  home.file.".pi/agent/sessions".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/sessions;
}
