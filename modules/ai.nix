{ lib, ... }: {
  options.ai = lib.mkOption { type = lib.types.attrs; };
  config.ai = {
    deepseek-official = {
      name = "Deepseek Official Latest";
      model = "deepseek-chat";
      base_url = "https://api.deepseek.com/v1";
      api_key = lib.trim (builtins.readFile "/home/xieby1/Gist/Vault/deepseek_api_key_nvim.txt");
      cost_per_1m_in = 2;
      cost_per_1m_out = 3;
      cost_per_1m_in_cached = 0.2;
      cost_per_1m_out_cached = 3;
      context_window = 128000;
      default_max_tokens = 4000;
    };
    deepseek-siliconflow = {
      name = "siliconflow-deepseek";
      model = "Pro/deepseek-ai/DeepSeek-V3.2";
      base_url = "https://api.siliconflow.cn/v1";
      api_key = lib.trim (builtins.readFile "/home/xieby1/Gist/Vault/siliconflow_api_key_chatbox.txt");
    };
  };
}
