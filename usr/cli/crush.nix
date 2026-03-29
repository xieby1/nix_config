{ pkgs, ... }: {
  home.packages = [
    (import pkgs.npinsed.nur-charmbracelet {}).crush
  ];
  yq-merge.".config/crush/crush.json".text = builtins.toJSON {
    providers = {
      deepseek = {
        type = "openai-compat";
        base_url = "https://api.deepseek.com/v1";
        api_key = "$(cat ~/Gist/Vault/deepseek_api_key_nvim.txt)";
        models = [{
          id = "deepseek-chat";
          name = "Deepseek Latest";
          cost_per_1m_in = 2;
          cost_per_1m_out = 3;
          cost_per_1m_in_cached = 0.2;
          cost_per_1m_out_cached = 3;
          context_window = 128000;
          default_max_tokens = 4000;
        }];
      };
    };
  };
}
