{ config, ... }: {
  imports = [
    (import ./catwalk-to-custom-provider.nix config.ai.jw2-kimi)
    (import ./catwalk-to-custom-provider.nix config.ai.jw2-openai)

    # jw-deepseek proxy rejects 'developer' role (only accepts system/user/assistant/tool).
    # Setting supportsDeveloperRole=false makes pi send the system prompt as 'system' instead.
    # {yq-merge.".pi/agent/models.json".expr.providers.jw-deepseek.compat.supportsDeveloperRole = false;}
    # (import ./catwalk-to-custom-provider.nix config.ai.jw-deepseek)
  ];
  yq-merge.".pi/agent/auth.json" = {
    generator = builtins.toJSON;
    expr = {
      kimi-coding = {type="api_key"; key=config.ai.kimi.api_key;};
      deepseek = {type="api_key"; key=config.ai.deepseek.api_key;};
    };
  };
}
