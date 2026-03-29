{ lib, ... }: {
  options.ai = lib.mkOption { type = lib.types.attrs; };
  config.ai = {
    deepseek = {
      base_url = "https://api.deepseek.com/v1";
      api_key = lib.trim (builtins.readFile "/home/xieby1/Gist/Vault/deepseek_api_key_nvim.txt");
      models.latest = rec {
        name = "Official Deepseek Latest";
        id = "deepseek-chat";
        cost_per_1m_in = 2;
        cost_per_1m_out = 3;
        cost_per_1m_in_cached = 0.2;
        cost_per_1m_out_cached = cost_per_1m_out;
        context_window = 128000;
        default_max_tokens = 4000;
      };
    };
    siliconflow = {
      base_url = "https://api.siliconflow.cn/v1";
      api_key = lib.trim (builtins.readFile "/home/xieby1/Gist/Vault/siliconflow_api_key_chatbox.txt");
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
      };
    };
  };
}
