{ pkgs, lib, ... }: let
  catwalk-providers = import ./catwalk-providers pkgs;
in {
  imports = [
    ./mcp.nix
  ];
  # TODO: Precisely define the type
  options.ai = lib.mkOption { type = lib.types.attrs; };
  config.ai = rec {
    deepseek = catwalk-providers.deepseek // {
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/deepseek_api_key_nvim.txt);
    };
    minimax-china = catwalk-providers.minimax-china // rec {
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/minimax.txt);
      # The catwalk-providers.minimax-china.models.xxx does not contain can_reason field.
      # Add the can_reason field here.
      # TODO: Precisely define the type, so we can avoid the missing field.
      models = builtins.mapAttrs (
        _: model: model // {
          can_reason = true;
          supports_attachments = true;
        }
      ) catwalk-providers.minimax-china.models;
      default_small_model_id = let x="MiniMax-M2"; in assert models?${x}; x;
    };
    kimi = catwalk-providers.kimi // {
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/kimi.txt);
    };
    tavily.api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/tavily.txt);
    jw-claude = catwalk-providers.anthropic // {
      id = "jw-claude";
      name = "JW Claude";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw-claude.txt);
    };
    jw-codex = {
      id = "jw-codex";
      name = "JW Codex";
      type = "openai";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw-codex.txt);
      default_large_model_id = "gpt-5.5";
      default_small_model_id = "gpt-5.4";
      models = {
        "gpt-5.5" = {
          id = "gpt-5.5";
          name = "gpt-5.5";
          context_window = 256 * 1000; # yes, jw gpt-5.5 is 256k

          # TODO: Precisely define the type, so we can avoid the missing field.
          can_reason = true;
          cost_per_1m_in = 0;
          cost_per_1m_out = 0;
          cost_per_1m_in_cached = 0;
          cost_per_1m_out_cached = 0;
          default_max_tokens = 4000;
        } // {supports_attachments = true;};
        "gpt-5.4" = {
          id = "gpt-5.4";
          name = "gpt-5.4";
          context_window = 1000 * 1000;

          # TODO: Precisely define the type, so we can avoid the missing field.
          can_reason = true;
          cost_per_1m_in = 0;
          cost_per_1m_out = 0;
          cost_per_1m_in_cached = 0;
          cost_per_1m_out_cached = 0;
          default_max_tokens = 4000;
        } // {supports_attachments = true;};
      };
    };
    jw-codex-2 = jw-codex // {
      id = "jw-codex-2";
      name = "JW Codex 2";
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/LLMs/jw-codex-2.txt);
    };
    jw-deepseek = catwalk-providers.deepseek // {
      id = "jw-deepseek";
      name = "JW DeepSeek";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw-url.txt) + "/v1";
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/LLMs/jw-deepseek.txt);
    };
    jw-kimi = catwalk-providers.kimi // {
      id = "jw-kimi";
      name = "JW Kimi";
      api_endpoint = lib.trim (builtins.readFile ~/Gist/Vault/AI/jw-url.txt);
      api_key = lib.trim (builtins.readFile ~/Gist/Vault/AI/LLMs/jw-kimi.txt);
    };
  };
}
