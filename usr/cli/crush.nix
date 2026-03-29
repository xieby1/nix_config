{ pkgs, config, ... }: {
  home.packages = [
    (import pkgs.npinsed.nur-charmbracelet {}).crush
  ];
  yq-merge.".config/crush/crush.json".text = builtins.toJSON {
    providers = {
      deepseek = {
        type = "openai-compat";
        inherit (config.ai.deepseek) base_url api_key;
        models = [config.ai.deepseek.models.latest];
      };
      deepseek-siliconflow = {
        type = "openai-compat";
        inherit (config.ai.siliconflow) base_url api_key;
        models = [
          config.ai.siliconflow.models.deepseek
        ];
      };
    };
  };
}
