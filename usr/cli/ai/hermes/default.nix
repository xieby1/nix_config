{ pkgs, lib, config, ... }: {
  home.packages = [
    # llm-agents.hermes-agent vs hermes-agent/flake.nix
    # - llm-agents.hermes-agent non-cached closure size: 278,345,760B
    # - hermes-agent/flake.nix non-cached closure size: 1,336,474,112B
    # Thus llm-agents.hermes-agent is preferred
    (pkgs.flake-compat {src=pkgs.npinsed.ai.llm-agents;})
      .defaultNix.packages.${pkgs.stdenv.system}.hermes-agent
  ];
  yq-merge.".hermes/config.yaml" = {
    generator = builtins.toJSON;
    expr = {
      model = {
        default = "kimi-for-coding";
        provider = "kimi-coding";
        base_url = config.ai.kimi.api_endpoint;
      };
    };
  };
  yq-merge.".hermes/.env" = {
    generator = lib.generators.toKeyValue {};
    yqExtraArgs = "-p=props -o=props --properties-separator='='";
    yqLoadFunc = "load_props";
    expr = {
      KIMI_API_KEY = config.ai.kimi.api_key;
    };
  };
}
