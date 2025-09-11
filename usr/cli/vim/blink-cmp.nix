{ pkgs, ... }: { programs.neovim = {
  plugins = [{
    plugin = pkgs.vimPlugins.blink-cmp;
    type = "lua";
    config = /*lua*/ ''
      require("blink.cmp").setup({
        keymap = { preset = 'super-tab' },
        completion = {
          documentation = { auto_show = true },
          menu = {
            draw = {
              columns = { {'kind_icon'}, {'label', 'label_description', gap = 1}, {'source_name'}, },
            },
          },
        },
        sources = {
          default = { 'lsp', 'path', 'buffer', 'snippets', 'minuet' },
          providers = {
            minuet = {
              name = 'minuet',
              module = 'minuet.blink',
              async = true,
              -- Should match minuet.config.request_timeout * 1000,
              -- since minuet.config.request_timeout is in seconds
              timeout_ms = 3000,
              score_offset = 50, -- Gives minuet higher priority among suggestions
            },
          },
        },
      })
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })
    '';
  }];
};}
