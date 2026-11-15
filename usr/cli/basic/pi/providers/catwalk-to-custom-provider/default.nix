catwalk: {
  yq-merge.".pi/agent/models.json" = {
    generator = builtins.toJSON;
    expr = {
      providers = {
        ${catwalk.id} = {
          baseUrl = catwalk.api_endpoint;
          api =  if catwalk.type == "messages" then "anthropic-messages"
            else if catwalk.type == "responses" then "openai-responses"
            else if catwalk.type == "completions" then "openai-completions"
            else throw "Unknown api from catwalk.type ${catwalk.type}";
          apiKey = catwalk.api_key;
          models = builtins.attrValues (builtins.mapAttrs (
            _: model: {
              inherit (model) id name;
              reasoning = builtins.elem model.reasoning.thinking [ "always" "toggleable" ];
              input = ["text"] ++ (if model.capabilities.vision then ["image"] else []);
              cost = {
                input = model.pricing.input;
                output = model.pricing.output;
                cacheRead = model.pricing.cache_hit or 0;
                cacheWrite = model.pricing.cache_create or 0;
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
