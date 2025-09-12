#MC # completion
#MC # blink-cmp vs nvim-cmp
#MC # * as the config looks too hacking and too many issues remaining unsolved in github
#MC # * and nvim-cmp last maintain is 5 months ago, blink-cmp is 5 days ago.
#MC # * and minuet-ai-nvim delay in nvim-cmp and not solved, blink-cmp is async
{ pkgs, ... }: { programs.neovim = {
  plugins = [{
    plugin = pkgs.vimPlugins.blink-cmp;
    type = "lua";
    config = /*lua*/ ''
      require("blink.cmp").setup({
        keymap = { preset = 'none',
          ['<Tab>']   = { 'select_next', 'fallback' },
          ['<S-Tab>'] = { 'select_prev', 'fallback' },
          ['<Up>']   = { function(cmp) return cmp.select_prev({ auto_insert = false }) end, 'fallback' },
          ['<Down>'] = { function(cmp) return cmp.select_next({ auto_insert = false }) end, 'fallback' },
          ['<CR>'] = { 'accept', 'fallback' },
        },
        completion = {
          documentation = { auto_show = true },
          menu = {
            draw = {
              columns = { {'kind_icon'}, {'label', 'label_description', gap = 1}, {'source_name'}, },
            },
          },
          list = { selection = { preselect = false }, },
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
