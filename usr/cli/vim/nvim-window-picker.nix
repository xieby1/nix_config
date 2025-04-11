#MC # nvim-window-picker
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-window-picker;
      type = "lua";
      config = ''
        require 'window-picker'.setup({
          selection_chars = 'abcdefghijklmnopqrstuvwxyz',
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
