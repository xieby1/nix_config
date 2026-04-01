# # Alternatives Comparisons
#
# ## Opencode
#
# - Pros:
#   - Javascript based. The nix closure is not so large: 186MB!
# - Cons:
#   - Lack of doc, currently I care about customized providers.
#   - Does not support terminal scrollback.
#   - Use Esc instead of Ctrl-C to interrupt.
#   - ~~The input line does not support Home, End key.~~
#   - Token inefficiency
# - Summary: Its quality is not comparable to neovim,
#            though it declares "OpenCode is built by neovim users ...".
#
# ## Crush
#
# - Pros:
#   - Go lang based.
# - Cons:
#   - Token inefficiency: 300 line system prompt and cannot fully customize,
#                         only supports system prompt prefix.
#   - The input line support Home, End key, but does not support Ctrl+Left/Right.
#   - Does not support terminal scrollback.
#   - Notification cannot click and jump to the corresponding terminal.
#
# ## Aider
#
# - Pros:
#   - Support script
#   - Token efficiency
#     - Test Prompt: Introduce yourself
#       - Aider: 2.3k
#       - Crush: 15K
#   - Native input line support: scrollback, Ctrl-Left/Right, ...
# - Cons:
#   - Python based, large codebase: nix closure > 2GB
#   - Does not support skill, memory.
#   - Models are out of date, e.g.: minimax 2.5, while latest is 2.7
{ pkgs, config, ... }: {
  home.packages = [
    (import pkgs.npinsed.nur-charmbracelet {}).crush
  ];
  yq-merge.".config/crush/crush.json".text = builtins.toJSON {
    providers = {
      # Catwalk includes deepseek
      deepseek.api_key = config.ai.deepseek.api_key;
      siliconflow = {
        type = "openai-compat";
        inherit (config.ai.siliconflow) api_endpoint api_key;
        extra_body = {
          # TODO: Why the think is enable by default for customized providers?
          enable_thinking = false;
        };
        models = builtins.attrValues config.ai.siliconflow.models;
      };
      # Catwalk includes minimax-china
      minimax-china.api_key = config.ai.minimax-china.api_key;
    };
    options = {
      tui = {
        transparent = true;
      };
    };
  };
}
