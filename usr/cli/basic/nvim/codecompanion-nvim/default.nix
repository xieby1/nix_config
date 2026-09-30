# TODO: Let blink.cmp fetch words from codecompanion buffer
#MC # Code Companion: AI
{ pkgs, config, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "codecompanion";
      src = pkgs.npinsed.nvim.codecompanion;
      patches = [
        # For codecompanion ACP tools calls: display tool call input and output
        ./preserve-acp-raw-tool-io.patch
        # Keep CodeCompanion slash completions from outranking normal path completion.
        ./blink-completion-path-friendly.patch
      ];
      # For codecompanion native tools calls: display with longer truncation
      postPatch = ''
        substituteInPlace lua/codecompanion/interactions/chat/acp/formatters.lua \
          --replace-fail 'local MAX_TITLE = 60' 'local MAX_TITLE = 999' \
          --replace-fail 'local MAX_TEXT = 100' 'local MAX_TEXT = 999'
      '';
      doCheck = false;
    };
    type = "lua";
    # https://codecompanion.olimorris.dev/configuration/adapters.html
    config = /*lua*/ ''
      require("codecompanion").setup({
        adapters = {
          acp = {
            pi = function()
              return require("codecompanion.adapters.acp").extend("opencode", {
                name = "pi",
                formatted_name = "Pi",
                commands = { default = { "pi-acp", }, },
              })
            end,
          },
        },
        display = {
          chat = {
            window = {
              position = "left",
              width = 40,
              -- call api.nvim_set_option_value(k, v, { scope = "local", win = winnr }) for each k,v in opts
              opts = {
                winfixwidth = true,
              },
            },
            diff = { enabled = true },
            fold_reasoning = false,
            -- Adapter can't be changed when `display.chat.show_settings = true`
            -- Fine!
            -- show_settings = true,
          },
        },
        strategies = {
          chat = { adapter = "pi", },
          inline = { adapter = "pi", },
        },
      })

      -- key bindings of AI
      vim.keymap.set('n', '<leader>a', ':CodeCompanionChat Toggle<CR>')
      vim.keymap.set('v', '<leader>a', ':CodeCompanionChat Add<CR>')
    '';
  }];

  home.shellAliases.codecompanion=''nvim -c CodeCompanionChat -c "bd 1"'';
}
