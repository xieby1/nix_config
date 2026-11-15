let
  lib = (import <nixpkgs> {}).lib;
  model = {
    id = "test-model";
    name = "Test Model";
    reasoning = true;
    modalities = { input = [ "text" "image" "video" ]; output = [ "text" ]; };
    cost = { input = 1; output = 2; cache_read = 0.1; cache_write = 0.2; };
    limit = { context = 100000; output = 10000; };
  };
  convert = api: models: (import ./. {
    id = "test-provider";
    api_endpoint = "https://example.invalid/v1";
    api_key = "test-key";
    inherit api models;
  }).yq-merge.".pi/agent/models.json".expr.providers.test-provider;
in lib.debug.throwTestFailures { failures = lib.runTests {
  test-explicit-protocol = {
    expr = (convert "openai-responses" { inherit model; }).api;
    expected = "openai-responses";
  };
  test-model-metadata = {
    expr = (convert "openai-responses" { inherit model; }).models;
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
    expr = (builtins.head (convert "openai-completions" {
      model = model // { cost = { input = 1; output = 2; }; };
    }).models).cost;
    expected = { input = 1; output = 2; cacheRead = 0; cacheWrite = 0; };
  };
  test-attachment-is-not-vision = {
    expr = let
      converted = builtins.head (convert "openai-completions" {
        model = model // {
          reasoning = false;
          attachment = true;
          modalities = { input = [ "text" "pdf" ]; output = [ "text" ]; };
        };
      }).models;
    in { inherit (converted) reasoning input; };
    expected = { reasoning = false; input = [ "text" ]; };
  };
  test-exclude-specialized-models = {
    expr = map (m: m.id) (convert "openai-responses" {
      inherit model;
      embedding = { type = "embedding"; };
      image = { type = "image"; };
      realtime = { type = "realtime"; };
    }).models;
    expected = [ "test-model" ];
  };
}; }
