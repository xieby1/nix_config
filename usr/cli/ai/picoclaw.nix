{ pkgs, ... }: {
  home.packages = [
    (pkgs.flake-compat {src=pkgs.npinsed.ai.llm-agents;})
      .defaultNix.packages.${pkgs.stdenv.system}.picoclaw
  ];
}
