catwalk: {
  yq-merge.".config/zerostack/config.json"= {
    expr = {
      custom_providers = {
        ${catwalk.id} = {
          provider_type = if catwalk.type == "anthropic" then "anthropic"
                     else if catwalk.type == "openai" then "openai"
                     else if catwalk.type == "openai-compat" then "openai"
                     else throw "Unknown provider_type from catwalk.type ${catwalk.type}";
          base_url = "${catwalk.api_endpoint}/v1";
        };
      };
      api_keys = {
        ${catwalk.id} = catwalk.api_key;
      };
    };
  };
}
