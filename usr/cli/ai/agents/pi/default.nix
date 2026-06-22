{ pkgs, ... }: {
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    (pkgs.flake-compat {src = pkgs.npinsed.ai.llm-agents;})
      .defaultNix.packages.x86_64-linux.pi
  ];
}
