#MC # telescope-nvim
{ config, pkgs, stdenv, lib, ... }: {
  imports = [
    ./fzf-native.nix
    ./live-grep-args.nix
    ./ui-select.nix
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.telescope-nvim;
      type = "lua";
      config = /*lua*/ ''
        require('telescope').setup {
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
    }
      pkgs.vimPlugins.plenary-nvim
    ];
  };
}
