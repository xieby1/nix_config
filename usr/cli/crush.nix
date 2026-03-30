# Alternatives Comparisons
# - Opencode
#   - Cons:
#     - Lack of doc, currently I care about customized providers.
#     - Does not compatible with kitty scrollback.
#     - Use Esc instead of Ctrl-C to interrupt.
#     - The input line does not support Home, End key.
#   - Summary: Its quality is not comparable to neovim,
#              though it declares "OpenCode is built by neovim users ...".
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
        models = builtins.attrValues config.ai.siliconflow.models;
      };
      # Catwalk includes minimax-china
      minimax-china.api_key = config.ai.minimax-china.api_key;
    };
  };
}
