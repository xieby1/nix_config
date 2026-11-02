{ config, ... }: {
  imports = [
    (import ./catwalk-to-custom-provider.nix config.ai.jw2-openai)
    # allrouter.cc rejects Pi's session_id header (HTTP 400); keep x-client-request-id.
    {yq-merge.".pi/agent/models.json".expr.providers.acc-openai.compat.sessionAffinityFormat = "openai-nosession";}
    (import ./catwalk-to-custom-provider.nix config.ai.acc-gpt)

    # jw-deepseek proxy rejects 'developer' role (only accepts system/user/assistant/tool).
    # Setting supportsDeveloperRole=false makes pi send the system prompt as 'system' instead.
    {yq-merge.".pi/agent/models.json".expr.providers.jw2-deepseek.compat.supportsDeveloperRole = false;}
    (import ./catwalk-to-custom-provider.nix config.ai.jw2-deepseek)
  ];
  yq-merge.".pi/agent/auth.json" = {
    generator = builtins.toJSON;
    expr = {
      deepseek = {type="api_key"; key=config.ai.deepseek.api_key;};
    };
  };
}
