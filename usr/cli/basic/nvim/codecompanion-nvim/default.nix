# TODO: Let blink.cmp fetch words from codecompanion buffer
#MC # Code Companion: AI
{ pkgs, config, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.codecompanion-nvim.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        # Keep CodeCompanion slash completions from outranking normal path completion.
        ./blink-completion-path-friendly.patch
      ];
    });
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
            fold_reasoning = false,
            -- Adapter can't be changed when `display.chat.show_settings = true`
            -- Fine!
            -- show_settings = true,
          },
          diff = { enabled = true },
        },
        interactions = {
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
