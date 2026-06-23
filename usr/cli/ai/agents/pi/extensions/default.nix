# My feeling: configure javascript/typescript plugins is awful.
{ pkgs, ... }: {
  imports = [
    ./mcp.nix
    ./acp.nix
    ./pi-hermes-memory.nix
    ./rpiv-todo.nix
  ];
  home.file = {
    # tintinweb/pi-subagents (this) vs nicobailon/pi-subagents (previous)
    # - previous:
    #   - non-intuitive: need explicitly specify the subagents call
    # pi-subagents = {
    #   target = ".pi/agent/extensions/pi-subagents";
    #   source = pkgs.buildNpmPackage (finalAttrs: {
    #     name = "pi-subagents";
    #     src = pkgs.npinsed.ai.pi-subagents;
    #     npmDepsHash = "sha256-zau3eaJoa8pE3A5COXwyTLSesoePgYqrnRCg3SMSaAA=";
    #     dontNpmBuild = true;
    #   }) + /lib/node_modules/pi-subagents;
    # };

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
    ".pi/agent/extensions/pi-constell-plan" = {
      source = pkgs.npinsed.ai.pi.constell-plan + /packages/pi-constell;
    };

    ".pi/agent/extensions/titlebar-spinner.ts" = {
      source = (pkgs.flake-compat {src = pkgs.npinsed.ai.pi.llm-agents;})
        .defaultNix.packages.x86_64-linux.pi
        +"/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/titlebar-spinner.ts";
    };
  };
}
