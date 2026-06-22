{ config, ... }: {
  imports = [
    (import ./catwalk-to-custom-provider.nix config.ai.jw-codex)
  ];
  yq-merge.".pi/agent/auth.json" = {
    generator = builtins.toJSON;
    expr = {
      minimax-cn = {type="api_key"; key=config.ai.minimax-china.api_key;};
      kimi-coding = {type="api_key"; key=config.ai.kimi.api_key;};
      deepseek = {type="api_key"; key=config.ai.deepseek.api_key;};
    };
  };
  yq-merge.".pi/agent/settings.json" = {
    generator = builtins.toJSON;
    expr = {
      defaultProvider = config.ai.jw-codex.id;
      defaultModel = config.ai.jw-codex.default_large_model_id;
    };
  };
}
