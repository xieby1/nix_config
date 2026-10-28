{ config, pkgs, ... }:
{
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    # Include session-file size (S5.5M) in Pi's built-in footer stats line.
    # Retry rejected basispoints tool transport corrections with Pi's native retry policy.
    (pkgs.pipkgs.pi-coding-agent.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./footer-session-size.patch ./basispoints-retry.patch ];
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
      # every scroll; "regular" lets kitty scroll its own (fast) scrollback buffer.
      tuiMode = "regular";
    };
  };

  home.file.".pi/agent/sessions".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/sessions;
}
