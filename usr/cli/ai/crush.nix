{ pkgs, config, ... }: {
  home.packages = [
    (import pkgs.npinsed.nur-charmbracelet {}).crush
  ];
  yq-merge.".config/crush/crush.json" = { generator = builtins.toJSON; expr = {
    providers = {
      # Catwalk includes deepseek
      deepseek.api_key = config.ai.deepseek.api_key;
      siliconflow = {
        type = "openai-compat";
        inherit (config.ai.siliconflow) api_endpoint api_key;
        extra_body = {
          # TODO: Why the think is enable by default for customized providers?
          enable_thinking = false;
        };
        models = builtins.attrValues config.ai.siliconflow.models;
      };
      # Catwalk includes minimax-china
      minimax-china.api_key = config.ai.minimax-china.api_key;
    };
    options = {
      tui = {
        transparent = true;
      };
    };
  };};
}
