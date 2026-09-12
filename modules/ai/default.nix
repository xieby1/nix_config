{ pkgs, lib, ... }: let
  catwalk-providers = import ./catwalk-providers pkgs;
in {
  imports = [
    ./mcp.nix
  ];
  # TODO: Precisely define the type
  options.ai = lib.mkOption { type = lib.types.attrs; };
  config.ai = {
    deepseek = catwalk-providers.deepseek // {
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/deepseek_api_key_nvim.txt);
    };
    kimi = catwalk-providers.kimi // {
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/kimi.txt);
    };
    tavily.api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/tavily.txt);
    jw2-kimi = catwalk-providers.kimi // {
      id = "jw2-kimi";
      name = "JW2 Kimi";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-kimi.txt);
    };
    jw2-openai = catwalk-providers.openai // {
      id = "jw2-openai";
      name = "JW2 OpenAI";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw2-openai.txt);
      models = builtins.mapAttrs (
        _: model: model // {
          context_window = 353 * 1000;
        }
      ) catwalk-providers.openai.models;
    };
  };
}
