{ lib }: let
  models-dev-providers = import ./models-dev-providers {
    pkgs = import <nixpkgs> {};
    src = (import <npins> { input = ./sources.json; }).models-dev;
  };
in rec {
  default_small = {
    provider = "jw2-deepseek";
    model = jw2-deepseek.models.deepseek-flash;
  };
  # default_large_model = jw2-openai.models."gpt-6.1-sol";
  deepseek = models-dev-providers.deepseek // {
    api_key = lib.trim (builtins.readFile ~/Gist/Vault/deepseek_api_key_nvim.txt);
  };
  tavily.api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/tavily.txt);
  jw2-openai = models-dev-providers.openai // {
    id = "jw2-openai";
    name = "JW2 OpenAI";
    api = "openai-responses";
    api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt);
    api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-openai.txt);
    models = builtins.mapAttrs (
      _: model: model // {
        limit = model.limit // { context = 353 * 1000; };
      }
    ) models-dev-providers.openai.models;
  };
  jw2-deepseek = models-dev-providers.deepseek // {
    id = "jw2-deepseek";
    name = "JW2 DeepSeek";
    api = "openai-completions";
    api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt) + "/v1";
    api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-deepseek.txt);
    models.deepseek-flash = models-dev-providers.deepseek.models.deepseek-flash // {
      id = "deepseek-flash";
      name = "DeepSeek-Flash";
    };
  };
  acc-gpt = models-dev-providers.openai // {
    id = "acc-openai";
    name = "ACC OpenAI";
    api = "openai-responses";
    api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/aacc/url.txt);
    api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/aacc/gpt.txt);
    models = builtins.mapAttrs (
      _: model: model // {
        limit = model.limit // { context = 353 * 1000; };
      }
    ) models-dev-providers.openai.models;
  };
}
