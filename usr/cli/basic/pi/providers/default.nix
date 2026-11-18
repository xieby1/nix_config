{ ai, ... }: {
  imports = [
    (import ./models-dev-to-custom-provider ai.jw2-openai)
    (import ./models-dev-to-custom-provider ai.jw2-kimi)
    # allrouter.cc rejects Pi's session_id header (HTTP 400); keep x-client-request-id.
    {yq-merge.".pi/agent/models.json".expr.providers.acc-openai.compat.sessionAffinityFormat = "openai-nosession";}
    (import ./models-dev-to-custom-provider ai.acc-gpt)

    # jw-deepseek proxy rejects 'developer' role (only accepts system/user/assistant/tool).
    # Setting supportsDeveloperRole=false makes pi send the system prompt as 'system' instead.
    {yq-merge.".pi/agent/models.json".expr.providers.jw2-deepseek.compat.supportsDeveloperRole = false;}
    (import ./models-dev-to-custom-provider ai.jw2-deepseek)
  ];
  yq-merge.".pi/agent/auth.json" = {
    generator = builtins.toJSON;
    expr = {
      deepseek = {type="api_key"; key=ai.deepseek.api_key;};
    };
  };
  home.file = {
    ".pi/agent/extensions/jw2-sub2api-pi-codex".source =
      if builtins.pathExists ~/Gist/Vault/AI/jw2/sub2api-pi-codex then
        ~/Gist/Vault/AI/jw2/sub2api-pi-codex
      else null;
  };
}
