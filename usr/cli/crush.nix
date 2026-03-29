{ pkgs, config, ... }: {
  home.packages = [
    (import pkgs.npinsed.nur-charmbracelet {}).crush
  ];
  yq-merge.".config/crush/crush.json".text = builtins.toJSON {
    providers = {
      deepseek = {
        type = "openai-compat";
        inherit (config.ai.deepseek-official) base_url api_key;
        models = [{
          id = config.ai.deepseek-official.model;
          inherit (config.ai.deepseek-official)
            name
            cost_per_1m_in
            cost_per_1m_out
            cost_per_1m_in_cached
            cost_per_1m_out_cached
            context_window
            default_max_tokens
          ;
        }];
      };
      deepseek-siliconflow = with config.ai.deepseek-siliconflow; {
        type = "openai-compat";
        inherit base_url api_key;
        models = [{
          id = model;
          inherit name
            cost_per_1m_in cost_per_1m_out
            cost_per_1m_in_cached cost_per_1m_out_cached
            context_window;
        }];
      };
    };
  };
}
