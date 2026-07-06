{ pkgs, ... }: {
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    # TODO: using pi in pkgsu?
    (pkgs.flake-compat {src = pkgs.npinsed.ai.pi.llm-agents;})
      .defaultNix.packages.x86_64-linux.pi
  ];

  yq-merge.".pi/agent/settings.json".expr.retry = {
    enabled = true;
    maxRetries = 6;
    baseDelayMs = 1000;
  };
}
