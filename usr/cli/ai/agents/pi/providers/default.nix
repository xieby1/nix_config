{ config, ... }: {
  imports = [
    (import ./catwalk-to-custom-provider.nix config.ai.jw-codex)
    (import ./catwalk-to-custom-provider.nix config.ai.jw-codex-2)
    (import ./catwalk-to-custom-provider.nix config.ai.jw-claude)
    (import ./catwalk-to-custom-provider.nix config.ai.jw-kimi)

    # jw-deepseek proxy rejects 'developer' role (only accepts system/user/assistant/tool).
    # Setting supportsDeveloperRole=false makes pi send the system prompt as 'system' instead.
    {yq-merge.".pi/agent/models.json".expr.providers.jw-deepseek.compat.supportsDeveloperRole = false;}
    (import ./catwalk-to-custom-provider.nix config.ai.jw-deepseek)
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
