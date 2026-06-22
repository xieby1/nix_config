{ config, ... }: {
  imports = [
    (import ./catwalk-to-custom-provider config.ai.minimax-china)
    (import ./catwalk-to-custom-provider config.ai.kimi)
    (import ./catwalk-to-custom-provider config.ai.deepseek)
  ];
  yq-merge.".pi/agent/settings.json" = {
    generator = builtins.toJSON;
    expr = {
      defaultProvider = config.ai.minimax-china.id;
      defaultModel = config.ai.minimax-china.default_large_model_id;
    };
  };
}
