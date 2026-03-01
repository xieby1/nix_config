#MC # nvim-window-picker
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-window-picker;
      type = "lua";
      config = ''
        require 'window-picker'.setup({
          selection_chars = 'abcdefghijklmnopqrstuvwxyz',
          picker_config = {
            statusline_winbar_picker = {
              selection_display = function(char, windowid)
                return '[' .. char .. ']' .. vim.o.statusline
              end,
            },
          },
          show_prompt = false,
          highlights = {
            statusline = {
              unfocused = {
                fg = '#2c2e34',
                bg = '#7f8490',
                bold = true,
              },
            },
          },
        })
        vim.keymap.set('n', '<C-j>', function()
          vim.api.nvim_set_current_win( require('window-picker').pick_window() )
        end)
        vim.keymap.set('n', '<C-w>j', function()
          vim.api.nvim_set_current_win( require('window-picker').pick_window() )
        end)
      '';
    }];
  };
}
