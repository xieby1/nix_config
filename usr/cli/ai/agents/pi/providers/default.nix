{ config, ... }: {
  imports = [
    (import ./catwalk-to-custom-provider config.ai.minimax-china)
    (import ./catwalk-to-custom-provider config.ai.kimi)
    (import ./catwalk-to-custom-provider config.ai.deepseek)
    (import ./catwalk-to-custom-provider config.ai.jw-codex)
  ];
  yq-merge.".pi/agent/settings.json" = {
    generator = builtins.toJSON;
    expr = {
      defaultProvider = config.ai.jw-codex.id;
      defaultModel = config.ai.jw-codex.default_large_model_id;
    };
  };
}
