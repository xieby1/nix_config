let
  pkgs = import <nixpkgs> {};
# llm-agents.hermes-agent vs hermes-agent/flake.nix
# llm-agents.hermes-agent
# - Pros:
#   - non-cached closure size: 278,345,760B
# - Cons:
#   - Update less frequently, thus bugs cannot be fixed in time
# hermes-agent/flake.nix
# - Cons:
#  - non-cached closure size: 404,901,944B
in (pkgs.flake-compat {
  src = pkgs.applyPatches {
    src = pkgs.npinsed.ai.hermes-agent;
    name = "hermes-source-code";
    patches = [
      # Add project-local skill discovery#17328 (rebased for v2026.5.7)
      ./project-local-skills.patch
      # Remember last session-only /model switch across CLI/TUI restarts.
      ./remember-last-used-model.patch
      # Ship plugin.yaml manifests so bundled backend plugins (web providers, etc.) load in packaged builds.
      ./package-plugin-manifests.patch
      # List all skills in `hermes insights`
      ./insights-list-all-skills.patch
      # TUI status bar: estimate context usage when provider omits response.usage
      ./tui-context-usage-fallback-estimation.patch
      # Classic CLI status bar: estimate context usage when provider omits response.usage
      ./cli-context-usage-fallback-estimation.patch
      # Show 50 rows in in-session recent-session views (/sessions, empty /resume, empty /history).
      ./recent-sessions-limit-50.patch
      # Render in-session recent-session rows oldest-to-newest so the most recent entry is nearest the prompt.
      ./recent-sessions-reverse-display-order.patch
    ];
  };
}).defaultNix.packages.${pkgs.stdenv.system}.default
.override {
  # Providers that route through Anthropic-compatible API need the anthropic
  # SDK pre-installed (nix store is read-only, pip install at runtime fails).
  extraDependencyGroups = [
    "anthropic"
    "messaging" # discord
  ];
}
