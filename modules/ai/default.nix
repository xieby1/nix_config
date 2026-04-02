{ pkgs, config, lib, ... }: let
  catwalk-providers = import ./catwalk-providers pkgs;
in {
  # TODO: Precisely define the type
  options.ai = lib.mkOption { type = lib.types.attrs; };
  config.ai = {
    deepseek = catwalk-providers.deepseek // {
      api_key = lib.trim (builtins.readFile "${config.home.homeDirectory}/Gist/Vault/deepseek_api_key_nvim.txt");
    };
    minimax-china = catwalk-providers.minimax-china // {
      api_key = lib.trim (builtins.readFile "${config.home.homeDirectory}/Gist/Vault/AI/minimax.txt");
      # The catwalk-providers.minimax-china.models.xxx does not contain can_reason field.
      # Add the can_reason field here.
      # TODO: Precisely define the type, so we can avoid the missing field.
      models = builtins.mapAttrs (
        _: model: model // {can_reason = true;}
      ) catwalk-providers.minimax-china.models;
    };
    siliconflow = {
      api_key = lib.trim (builtins.readFile "${config.home.homeDirectory}/Gist/Vault/siliconflow_api_key_chatbox.txt");
      api_endpoint = "https://api.siliconflow.cn/v1";
      models = {
        deepseek = rec {
          name = "Siliconflow Deepseek V3.2";
          id = "Pro/deepseek-ai/DeepSeek-V3.2";
          cost_per_1m_in = 2;
          cost_per_1m_out = 3;
          cost_per_1m_in_cached = 0.2;
          cost_per_1m_out_cached = cost_per_1m_out;
          context_window = 160*1000;
          # If not set the default_max_tokens is 0, then ai will output nothing.
          # TODO: Are there any other parameters are not intrinsics for a given model?
          #       How to set the the non-intrinsics parameters gracefully?
          default_max_tokens = 4000;
        };
        glm = rec {
          name = "Siliconflow GLM-5";
          id = "Pro/zai-org/GLM-5";
          # [0,32k): 4; [32k, inf): 6
          cost_per_1m_in = 6;
          # [0,32k): 18; [32k, inf): 22
          cost_per_1m_out = 22;
          # [0,32k): 1; [32k, inf): 1.5
          cost_per_1m_in_cached = 1.5;
          cost_per_1m_out_cached = cost_per_1m_out;
          context_window = 198*1000;
          default_max_tokens = 4000;
        };
        qwen = rec {
          name = "Siliconflow Qwen3.5";
          id = "Qwen/Qwen3.5-397B-A17B";
          # [0,128k): 1.2; [128k, 256k): 3
          cost_per_1m_in = 3;
          # [0,128k): 7.2; [128k, 256k): 18
          cost_per_1m_out = 18;
          cost_per_1m_in_cached = cost_per_1m_in;
          cost_per_1m_out_cached = cost_per_1m_out;
          context_window = 256*1000;
          default_max_tokens = 4000;
        };
        kimi = rec {
          name = "Siliconflow Kimi K2.5";
          id = "Pro/moonshotai/Kimi-K2.5";
          cost_per_1m_in = 4;
          cost_per_1m_out = 21;
          cost_per_1m_in_cached = 0.7;
          cost_per_1m_out_cached = cost_per_1m_out;
          context_window = 256*1000;
          default_max_tokens = 4000;
        };
      };
    };
    # TODO: Precisely define the type, so we can avoid the missing field.
    ollama = {
      api_key = "dummy";
      api_endpoint = "http://localhost:11434/v1";
      id = "ollama";
      models = {
        qwen3_5_9b = {
          name = "Qwen3.5 9B";
          id = "qwen3.5:9b";
          cost_per_1m_in = 0;
          cost_per_1m_out = 0;
          cost_per_1m_in_cached = 0;
          cost_per_1m_out_cached = 0;
          context_window = 32000; # TODO: ollama setting
          default_max_tokens = 4000;
          can_reason = true;
        };
      };
    };
  };
}
