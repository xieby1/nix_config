{ pkgs, lib, ... }: let
  models-dev-api_json = pkgs.callPackage ./models-dev-api {};
  models-dev-api = builtins.fromJSON (builtins.readFile models-dev-api_json);
in {
  cachix_packages = [
    models-dev-api_json
  ];
  _module.args.ai = rec {
    inherit models-dev-api;
    default_small = {
      provider = "jw2-deepseek";
      model = jw2-deepseek.models.deepseek-flash;
    };
    # default_large_model = jw2-openai.models."gpt-6.1-sol";
    deepseek = models-dev-api.deepseek // {
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/deepseek_api_key_nvim.txt);
    };
    tavily.api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/tavily.txt);
    jw2-openai = models-dev-api.openai // {
      id = "jw2-openai";
      name = "JW2 OpenAI";
      api = "openai-responses";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-openai.txt);
      models = builtins.mapAttrs (
        _: model: model // {
          limit = model.limit // { context = 353 * 1000; };
        }
      ) models-dev-api.openai.models;
    };
    jw2-deepseek = models-dev-api.deepseek // {
      id = "jw2-deepseek";
      name = "JW2 DeepSeek";
      api = "openai-completions";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt) + "/v1";
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-deepseek.txt);
      models.deepseek-flash = models-dev-api.deepseek.models.deepseek-flash // {
        id = "deepseek-flash";
        name = "DeepSeek-Flash";
      };
    };
    jw2-kimi = models-dev-api.kimi-code-plan-cn // {
      id = "jw2-kimi";
      name = "JW2 Kimi";
      api = "openai-responses";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-kimi.txt);
    };
    acc-gpt = models-dev-api.openai // {
      id = "acc-openai";
      name = "ACC OpenAI";
      api = "openai-responses";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/aacc/url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/aacc/gpt.txt);
      models = builtins.mapAttrs (
        _: model: model // {
          limit = model.limit // { context = 353 * 1000; };
        }
      ) models-dev-api.openai.models;
    };
  };
}
