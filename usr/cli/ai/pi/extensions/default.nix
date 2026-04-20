{ pkgs, ... }: {
  home.file = {
    pi-subagents = {
      target = ".pi/agent/extensions/pi-subagents";
      source = pkgs.npinsed.ai.pi-subagents;
    };
    pi-web-access = {
      target = ".pi/agent/extensions/pi-web-access";
      source = pkgs.buildNpmPackage (finalAttrs: {
        name = "pi-web-access";
        src = pkgs.npinsed.ai.pi-web-access;
        # The package-lock.json in src is out of date, so we need to manually specify npmDepsHash
        # npmDeps = pkgs.importNpmLock { npmRoot = pkgs.npinsed.ai.pi-web-access; };
        npmDepsHash = "sha256-zau3eaJoa8pE3A5COXwyTLSesoePgYqrnRCg3SMSarw=";
        dontNpmBuild = true;
      }) + /lib/node_modules/pi-web-access;
    };
    pi-skill-evolution = {
      target = ".pi/agent/extensions/pi-skill-evolution";
      source = pkgs.npinsed.ai.pi-skill-evolution;
    };
  };
}
