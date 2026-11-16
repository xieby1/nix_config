{ src }:
# Pi updates independently of the main Nixpkgs pin.
import src {
  overlays = [ (_: prev: {
    pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
      # Share gateway error classification between the native CLI and SDK retry paths.
      patches = (old.patches or [ ]) ++ [ ./native-retry/main.patch ];
      # Pi 1.5.0's nixpkgs install omits this runtime workspace dependency.
      # Upstream fix: https://github.com/NixOS/nixpkgs/pull/582756
      postInstall = old.postInstall + ''
        cp -r packages/schema "$out/lib/node_modules/pi-monorepo/node_modules/@earendil-works/pi-schema"
      '';
    });
  }) ];
}
