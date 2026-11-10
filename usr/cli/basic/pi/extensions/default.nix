{ enableExtendedCLI, sources, pipkgs }: # local-args
# My feeling: configure javascript/typescript plugins is awful.
{ pkgs, lib, ... }: {
  imports = [
    (lib.modules.importApply ./acp.nix {src = sources.acp;})
    (lib.modules.importApply ./pi-hermes-memory {src = sources.pi-hermes-memory; inherit pipkgs;})
    (lib.modules.importApply ./pi-co-authored-by.nix {src = sources.shelken-pi-extensions;})
    (lib.modules.importApply ./pi-math {src = sources.pi-math;})
    (lib.modules.importApply ./pi-language-tutor {src = sources.pi-language-tutor;})
    (lib.modules.importApply ./pi-retry.nix {src = sources.pi-retry;})
    (lib.modules.importApply ./pi-context-view {src = sources.pi-context-view;})
    (lib.modules.importApply ./pi-model-project.nix {
      src = sources.pi-model-project;
      piPackage = pipkgs.pi-coding-agent;
    })
    (lib.modules.importApply ./pi-skill-usage.nix {src = sources.pi-skill-usage;})
    (lib.modules.importApply ./heuristic-notify.nix {src = sources.pi-heuristic-notify;})
    (lib.modules.importApply ./pi-web-access {src = sources.pi-web-access;})
    (lib.modules.importApply ./pi-title {src = sources.pi-title + "/extensions/title";})
    ./ponytail
    (lib.modules.importApply ./rpiv-ask-user-question.nix {src = sources.rpiv-mono;})
    (lib.modules.importApply ./rpiv-todo {src = sources.rpiv-mono;})
  ] ++ lib.optionals enableExtendedCLI [
    ./pi-read-aloud
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
    # Compared with upstream pi examples/extensions/plan-mode:
    # - upstream example: read-only planning + in-session todo execution tracking with [DONE:n] markers.
    # - pi-constell-plan: clarification-gated plan-file export to ~/.pi-constell/plans/, Constellagent-compatible, no todo executor.
    # - pi-constell-plan keeps write/edit available only for the active plan file after askUserQuestion; upstream disables write/edit entirely.
    # - pi-constell-plan does not allow DDGS MCP.
    # - builtin plan-mode also has `/todos`, which is the same name as rpiv-todo

    ".pi/agent/extensions/titlebar-spinner.ts" = {
      source = pipkgs.pi-coding-agent.src
        + "/packages/coding-agent/examples/extensions/titlebar-spinner.ts";
    };
  };
}
