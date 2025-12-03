#MC # telescope-nvim
{ config, pkgs, stdenv, lib, ... }:
let
  my-telescope-nvim = {
    plugin = pkgs.vimPlugins.telescope-nvim;
    type = "lua";
    config = /*lua*/ ''
      -- search relative to file
      -- https://github.com/nvim-telescope/telescope.nvim/pull/902
      vim.keymap.set('n', '<space>f', function() require('telescope.builtin').find_files({cwd=require'telescope.utils'.buffer_dir()}) end)
      vim.keymap.set('n', '<space>F', require('telescope.builtin').find_files)
      vim.keymap.set('n', '<space>b', require('telescope.builtin').buffers)
      vim.keymap.set('n', '<space>h', require('telescope.builtin').help_tags)
      vim.keymap.set('n', '<space>t', require('telescope.builtin').treesitter)
      vim.keymap.set('n', '<space>c', require('telescope.builtin').command_history)
      vim.keymap.set('n', '<space>C', require('telescope.builtin').commands)
    '';
  };
  # Problem: unable to fuzzy search parenthesis '('
  # https://github.com/nvim-telescope/telescope-fzf-native.nvim/issues/141
  my-telescope-fzf-native-nvim = {
    plugin = pkgs.vimPlugins.telescope-fzf-native-nvim;
    type = "lua";
    config = /*lua*/ ''
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
    config = /*lua*/ ''
      require('telescope').load_extension("live_grep_args")
      vim.keymap.set('n', '<space>g', function() require("telescope").extensions.live_grep_args.live_grep_args({search_dirs={require"telescope.utils".buffer_dir()}}) end)
      vim.keymap.set('n', '<space>G', require("telescope").extensions.live_grep_args.live_grep_args)
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
