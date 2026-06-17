# TODO: use a template to generate following config
{ config, ... }: {
  yq-merge.".config/goose/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      providers = {
        ${config.ai.jw-codex.id} = {
          enabled = true;
          # TODO: redundant?
          model = config.ai.jw-codex.default_large_model_id;
          configured = true;
        };
      };
    };
  };
  yq-merge.".config/goose/custom_providers/${config.ai.jw-codex.id}.json" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      name = config.ai.jw-codex.id;
      # TODO: "openai-compat" => "openai"
      engine = "openai";
      display_name = config.ai.jw-codex.name;
      api_key_env = "JW_CODEX_API_KEY";
      base_url = config.ai.jw-codex.api_endpoint;
      dynamic_models = true;
      models = [];
      supports_streaming = true;
      requires_auth = true;
    };
  };
  yq-merge.".config/goose/secrets.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      JW_CODEX_API_KEY = config.ai.jw-codex.api_key;
    };
  };
}
