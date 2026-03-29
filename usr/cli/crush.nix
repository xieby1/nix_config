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
      siliconflow = {
        type = "openai-compat";
        inherit (config.ai.siliconflow) base_url api_key;
        extra_body = {
          # TODO: Why the think is enable by default for customized providers?
          enable_thinking = false;
        };
        models = [
          config.ai.siliconflow.models.deepseek
        ];
      };
    };
  };
}
