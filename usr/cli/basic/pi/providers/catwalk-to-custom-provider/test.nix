let
  lib = (import <nixpkgs> {}).lib;
  model = {
    id = "test-model";
    name = "Test Model";
    reasoning.thinking = "toggleable";
    capabilities.vision = true;
    pricing = { input = 1; output = 2; cache_hit = 0.1; cache_create = 0.2; };
    context_window = 100000;
    default_max_tokens = 10000;
  };
  convert = type: models: (import ./. {
    id = "test-provider";
    api_endpoint = "https://example.invalid/v1";
    api_key = "test-key";
    inherit type models;
  }).yq-merge.".pi/agent/models.json".expr.providers.test-provider;
in lib.runTests {
  test-api-types = {
    expr = map (type: (convert type { inherit model; }).api) [ "messages" "responses" "completions" ];
    expected = [ "anthropic-messages" "openai-responses" "openai-completions" ];
  };
  test-model-metadata = {
    expr = (convert "responses" { inherit model; }).models;
    expected = [{
      id = "test-model";
      name = "Test Model";
      reasoning = true;
      input = [ "text" "image" ];
      cost = { input = 1; output = 2; cacheRead = 0.1; cacheWrite = 0.2; };
      contextWindow = 100000;
      maxTokens = 10000;
    }];
  };
  test-optional-cache-pricing = {
    expr = (builtins.head (convert "completions" {
      model = model // { pricing = { input = 1; output = 2; }; };
    }).models).cost;
    expected = { input = 1; output = 2; cacheRead = 0; cacheWrite = 0; };
  };
  test-no-reasoning-or-vision = {
    expr = let
      converted = builtins.head (convert "completions" {
        model = model // {
          reasoning.thinking = "never";
          capabilities.vision = false;
        };
      }).models;
    in { inherit (converted) reasoning input; };
    expected = { reasoning = false; input = [ "text" ]; };
  };
  test-unknown-api = {
    expr = (builtins.tryEval (convert "unknown" { inherit model; }).api).success;
    expected = false;
  };
}
