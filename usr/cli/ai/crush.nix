# # Agents Comparisons
#
# ## Opencode
#
# - Pros:
#   - Javascript based. The nix closure is not so large: 186MB!
# - Cons:
#   - Javascript based. The memory consumption of open a new opencode instance: ~400MB
#   - Lack of doc, currently I care about customized providers.
#   - Does not support terminal scrollback.
#   - Use Esc instead of Ctrl-C to interrupt.
#   - ~~The input line does not support Home, End key.~~
#   - Token inefficiency
#   - Does not support explicit skill invocation: https://github.com/anomalyco/opencode/issues/7846
#     - Though opencode support /skill command, it still need natural language to trigger the skill.
#   - Copilot uses more premium requests: https://github.com/anomalyco/opencode/issues/11753, ...
# - Summary: Its quality is not comparable to neovim,
#            though it declares "OpenCode is built by neovim users ...".
#
# ## Crush
#
# - Pros:
#   - Go lang based.
#     - Small nix-closure.
#     - Small memory consumption: crush instance that have several conversations: ~70MB
# - Cons:
#   - Token inefficiency: 300 line system prompt and cannot fully customize,
#                         only supports system prompt prefix.
#   - The input line support Home, End key, but does not support Ctrl+Left/Right.
#   - Does not support terminal scrollback.
#   - Notification cannot click and jump to the corresponding terminal.
#   - Does not support explicit skill: https://github.com/charmbracelet/crush/discussions/2505 and no discussions!
#   - Generate `.crush/` in every folder where crush launched
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
#
# ## Codex
#
# - Cons:
#   - Latest verions only support wire_api = "responses",
#     does not support completion.
#     So does not support deepseek, minimax, ....
#     Fine!
#   - 603k source lines of rust, a pile of xxxx.
#
# ## Code (Codex Fork)
#
# - Pros:
#   - Support wire_api = "chat"
# - Cons:
#   - A fork that always needs to rebase.
#
# ## Forgecode
#
# - Cons:
#   - Claims being #1. Really?
#   - Fixed: ~The global local is ~/forge/, really!? I doubt the project's taste of tech.~~
#
# ## Goose
#
# - Cons:
#   - Why goose does not saved in nix binary cache, and 1.23.2 cannot build in x86-64 Linux: checkPhase failed!?
#     Why the compiling time so long 7min+?
#   - Why the output color render bug remain unsolved?
#     Oh, I guess this project focus on desktop, instead of cli.
#
# ## Avante.nvim
#
# - Pros:
#   - Leverages Neovim muscle memory
# - Cons:
#   - No skills support
#   - Uses plenary.nvim (curl without keepalive or auto-retry)
#     - Frequent network issues cause interruptions that disrupt workflow
#
# ## Codecompanion.nvim
#
# - Pros:
#   - Leverages Neovim muscle memory
#   - Minimal/Clean UI
# - Cons:
#   - Use plenary.nvim, the same to Avante.nvim.
#
# ## Hermes
#
# - Cons:
#   - Declare able to self-improvement (auto skill generating), but does not support per-project skill yet!?
#     https://github.com/NousResearch/hermes-agent/issues/4667
#     In my humble opinion, a auto-generating-skill skill is enough!
#
# Clients Comparisons
#
# ## Agentic.nvim
#
# - Pros:
#   - simple and only cares about ACP
# - Cons:
#   - does not support any ACP capabilities, including fs.readTextFile, fs.writeTextFile, terminal.
#     And it does not mentioned not support above ACP capabilities in doc.
#   - Bugs:
#     - when enter slash command like `/skill`, there is high, narrow auto completion floating window.
#     - Cannot disable insert by default
#     - Cannot hide winbar (need to edit source code)
#
# ## Codecompanion
#
# - Pros:
#   - simple UI!
#   - Support more ACP capabilities than Agentic.nvim: fs.readTextFile, fs.writeTextFile
#     And it explicitly state support of ACP capabilities in doc!
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
