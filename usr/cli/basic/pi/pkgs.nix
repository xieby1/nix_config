{ src }:
# Pi updates independently of the main Nixpkgs pin.
import src {
  overlays = [ (_: prev: {
    pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
      # Share gateway error classification between the native CLI and SDK retry paths.
      patches = (old.patches or [ ]) ++ [ ./native-retry/main.patch ];
    });
  }) ];
}
