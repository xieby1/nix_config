# TODO: use a template to generate following config
{ config, ... }: {
  yq-merge.".config/goose/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      providers = {
        ${config.ai.minimax-china.id} = {
          enabled = true;
          # TODO: redundant?
          model = config.ai.minimax-china.default_large_model_id;
          configured = true;
        };
      };
    };
  };
  yq-merge.".config/goose/custom_providers/${config.ai.minimax-china.id}.json" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      name = config.ai.minimax-china.id;
      engine = config.ai.minimax-china.type;
      display_name = config.ai.minimax-china.name;
      api_key_env = "MINIMAX_API_KEY";
      base_url = config.ai.minimax-china.api_endpoint;
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
      MINIMAX_API_KEY = config.ai.minimax-china.api_key;
    };
  };
}
