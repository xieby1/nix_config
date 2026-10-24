{ config, pkgs, ... }:
{
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    pkgs.pkgsu.pi-coding-agent
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
      # every scroll; "regular" lets kitty scroll its own (fast) scrollback buffer.
      tuiMode = "regular";
    };
  };

  home.file.".pi/agent/sessions".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/sessions;
}
