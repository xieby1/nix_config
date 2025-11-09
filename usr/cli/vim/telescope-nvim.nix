#MC # telescope-nvim
{ config, pkgs, stdenv, lib, ... }:
let
  my-telescope-nvim = {
    plugin = pkgs.vimPlugins.telescope-nvim;
    config = ''
      " search relative to file
      "" https://github.com/nvim-telescope/telescope.nvim/pull/902
      nnoremap ff <cmd>lua require('telescope.builtin').find_files({cwd=require'telescope.utils'.buffer_dir()})<cr>
      nnoremap fF <cmd>lua require('telescope.builtin').find_files()<cr>
      nnoremap fb <cmd>lua require('telescope.builtin').buffers()<cr>
      nnoremap fh <cmd>lua require('telescope.builtin').help_tags()<cr>
      nnoremap ft <cmd>lua require('telescope.builtin').treesitter()<cr>
      nnoremap fc <cmd>lua require('telescope.builtin').command_history()<cr>
      nnoremap fC <cmd>lua require('telescope.builtin').commands()<cr>
    '';
  };
  # Problem: unable to fuzzy search parenthesis '('
  # https://github.com/nvim-telescope/telescope-fzf-native.nvim/issues/141
  my-telescope-fzf-native-nvim = {
    plugin = pkgs.vimPlugins.telescope-fzf-native-nvim;
    type = "lua";
    config = ''
      require('telescope').setup {
        extensions = {fzf = {}},
        defaults = {
          layout_strategy = 'vertical',
          layout_config = {
            height = 0.95,
            width = 0.95,
            -- do not disable preview
            preview_cutoff = 1,
          },
        },
      }
      require('telescope').load_extension('fzf')
    '';
  };
  my-telescope-live-grep-args-nvim = {
    plugin = pkgs.vimPlugins.telescope-live-grep-args-nvim;
    type = "lua";
    config = ''
      require('telescope').load_extension("live_grep_args")

      -- nnoremap fg <cmd>lua require('telescope.builtin').live_grep({cwd=require'telescope.utils'.buffer_dir()})<cr>
      vim.keymap.set('n', 'fg', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args({search_dirs={require"telescope.utils".buffer_dir()}})<cr>')
      -- nnoremap fG <cmd>lua require('telescope.builtin').live_grep()<cr>
      vim.keymap.set('n', 'fG', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>')
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-telescope-nvim
      my-telescope-fzf-native-nvim
      pkgs.vimPlugins.plenary-nvim
      my-telescope-live-grep-args-nvim
    ];
  };
}
