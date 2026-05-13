{ pkgs, ... }: {
  home.packages = [
    # llm-agents.hermes-agent vs hermes-agent/flake.nix
    # - llm-agents.hermes-agent non-cached closure size: 278,345,760B
    # - hermes-agent/flake.nix non-cached closure size: 1,336,474,112B
    # Thus llm-agents.hermes-agent is preferred
    (pkgs.flake-compat {src=pkgs.npinsed.ai.llm-agents;})
      .defaultNix.packages.${pkgs.stdenv.system}.hermes-agent
  ];
}
