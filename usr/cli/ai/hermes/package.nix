let
  pkgs = import <nixpkgs> {};
# llm-agents.hermes-agent vs hermes-agent/flake.nix
# - llm-agents.hermes-agent non-cached closure size: 278,345,760B
# - hermes-agent/flake.nix non-cached closure size: 1,336,474,112B
# Thus llm-agents.hermes-agent is preferred
in (pkgs.flake-compat {src=pkgs.npinsed.ai.llm-agents;})
.defaultNix.packages.${pkgs.stdenv.system}.hermes-agent
.overrideAttrs (old: {
  patches = old.patches or [] ++ [
    # ACP configOptions for codecompanion.nvim model switching (ga)
    ./acp-configOptions.patch
    # Add project-local skill discovery#17328 (rebased for v2026.5.7)
    ./project-local-skills.patch
    # Remember last session-only /model switch across CLI/TUI restarts.
    ./remember-last-used-model.patch
    # Ship plugin.yaml manifests so bundled backend plugins (web providers, etc.) load in packaged builds.
    ./package-plugin-manifests.patch
    # List all skills in `hermes insights`
    ./insights-list-all-skills.patch
  ];
})
