catwalk: {
  yq-merge.".pi/agent/models.json" = {
    generator = builtins.toJSON;
    expr = {
      providers = {
        ${catwalk.id} = {
          baseUrl = catwalk.api_endpoint;
          api =  if catwalk.type == "anthropic" then "anthropic-messages"
            else if catwalk.type == "openai" then "openai-responses"
            else if catwalk.type == "openai-compat" then "openai-completions"
            else throw "Unknown api from catwalk.type ${catwalk.type}";
          apiKey = catwalk.api_key;
          models = builtins.attrValues (builtins.mapAttrs (
            _: model: {
              inherit (model) id name;
              reasoning = model.can_reason;
              input = ["text"];
              cost = {
                input = model.cost_per_1m_in;
                output = model.cost_per_1m_out;
                cacheRead = model.cost_per_1m_in_cached;
                cacheWrite = model.cost_per_1m_out_cached;
              };
              contextWindow = model.context_window;
              maxTokens = model.default_max_tokens;
            }
          ) catwalk.models);
        };
      };
    };
  };
}
