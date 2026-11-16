provider: {
  yq-merge.".pi/agent/models.json" = {
    generator = builtins.toJSON;
    expr.providers.${provider.id} = {
      baseUrl = provider.api_endpoint;
      api = provider.api;
      apiKey = provider.api_key;
      models = map (model: {
        inherit (model) id name reasoning;
        input = ["text"] ++ (if builtins.elem "image" model.modalities.input then ["image"] else []);
        cost = {
          inherit (model.cost) input output;
          cacheRead = model.cost.cache_read or 0;
          cacheWrite = model.cost.cache_write or 0;
        };
        contextWindow = model.workingContext;
        maxTokens = model.limit.output;
      }) (builtins.filter (model: (model.type or "chat") == "chat") (builtins.attrValues provider.models));
    };
  };
}
