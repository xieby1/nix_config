{ pkgs, lib, ... }: let
  models-dev-api_json = pkgs.callPackage ./models-dev-api {};
  models-dev-providers = withWorkingContext (builtins.fromJSON (builtins.readFile models-dev-api_json));
  # Conservative Pi budget, not the advertised limit or a measured effective length.
  withWorkingContext = builtins.mapAttrs (_: provider: provider // {
    models = builtins.mapAttrs (_: model: model // {
      workingContext = lib.min
        (model.limit.input or model.limit.context)
        (builtins.div model.limit.context 3);
    }) provider.models;
  });
in {
  cachix_packages = [
    models-dev-api_json
  ];
  _module.args.ai = rec {
    inherit models-dev-providers;
    default_small = {
      provider = jw2-deepseek;
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
    };
    jw2-sub2api-pi-codex = models-dev-providers.openai // {
      id = "jw2-sub2api-pi-codex";
      name = "JW2 sub2api-pi-codex";
      # TODO: remove api field from module.args.ai, use models-dev-providers.xxx.npm instead?
      api = "openai-responses";
    };
    jw2-deepseek = models-dev-providers.deepseek // {
      id = "jw2-deepseek";
      name = "JW2 DeepSeek";
      api = "openai-completions";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt) + "/v1";
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-deepseek.txt);
    };
    jw2-kimi = models-dev-providers.kimi-code-plan-cn // {
      id = "jw2-kimi";
      name = "JW2 Kimi";
      api = "openai-responses";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-kimi.txt);
    };
    acc-gpt = models-dev-providers.openai // {
      id = "acc-openai";
      name = "ACC OpenAI";
      api = "openai-responses";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/aacc/url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/aacc/gpt.txt);
    };
  };
}
