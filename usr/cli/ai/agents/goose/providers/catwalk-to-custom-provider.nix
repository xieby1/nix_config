lib: catwalk: let
  api_key_env = lib.toUpper (builtins.replaceStrings ["-"] ["_"] catwalk.id);
in {
  yq-merge.".config/goose/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      providers = {
        ${catwalk.id} = {
          enabled = true;
          # TODO: redundant?
          model = catwalk.default_large_model_id;
          configured = true;
        };
      };
    };
  };
  yq-merge.".config/goose/custom_providers/${catwalk.id}.json" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      name = catwalk.id;
      engine = if catwalk.type == "anthropic" then "anthropic"
          else if catwalk.type == "openai-compat" then "openai"
          else throw "Unknown engine from catwalk.type ${catwalk.type}";
      display_name = catwalk.name;
      inherit api_key_env;
      base_url = catwalk.api_endpoint;
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
      ${api_key_env} = catwalk.api_key;
    };
  };
}
