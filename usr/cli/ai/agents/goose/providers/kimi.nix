{ config, ... }: {
  yq-merge.".config/goose/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      providers = {
        ${config.ai.kimi.id} = {
          enabled = true;
          # TODO: redundant?
          model = config.ai.kimi.default_large_model_id;
          configured = true;
        };
      };
    };
  };
  yq-merge.".config/goose/custom_providers/${config.ai.kimi.id}.json" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      name = config.ai.kimi.id;
      engine = config.ai.kimi.type;
      display_name = config.ai.kimi.name;
      api_key_env = "KIMI_API_KEY";
      base_url = config.ai.kimi.api_endpoint;
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
      KIMI_API_KEY = config.ai.kimi.api_key;
    };
  };
}
