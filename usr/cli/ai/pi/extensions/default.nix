{ pkgs, ... }: {
  home.file = {
    # - pi-skill-evolution: needs pi-session-search which needs embedding provider (llm support embedding)
    # - pi-memory does not work: hard to trigger, too many slash commands
    # - taskplane: too complex, and subagent call does not work due to `npm root -g` cannot find pi, why not use $PATH?
    # - pi-messenger: communication cost too expensive
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
    # - Plan Extensions Comparison:
    #   - qmx/pi-plan-mode: fully read-only thus does not write md.
    #   - backnotprop/plannotator: I don't need the web annotation UI.
    #   - burneikis/pi-plan: no read-only support.
    # pi-constell-plan is a pi extension published by tridha643 from a fork that adds a packages/pi-constell directory to Owen
    # Gretzinger's original Constellagent desktop app, but its npm metadata incorrectly links to the upstream
    # owengretzinger/constellagent repo—which lacks that code—instead of the fork where the extension actually lives.
    #
    # OpenCode vs pi-constell-plan:
    # I test OpenCode plan mode and pi-constell-plan: using the prompt:
    # > Explain the essay "Memory dependence prediction using store sets" for me. You should first fetch it from internet, probably a
    # > pdf, then process pdf, then work on the content let me know what this paper it talk about.
    # OpenCode completely ignores plan mode, it call subagent to fetch pdf from the web, call subagent to explore, ...
    # pi-constell-plan obey perfectly: it write a plan file, then start follow the plan file.
    pi-constell-plan = {
      target = ".pi/agent/extensions/pi-constell-plan";
      source = pkgs.npinsed.ai.pi-constell-plan + /packages/pi-constell;
    };
  };
}
