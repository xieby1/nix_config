#MC # telescope-nvim
{ config, pkgs, stdenv, lib, ... }:
let
  my-telescope-ui-select-nvim = {
    plugin = pkgs.vimPlugins.telescope-ui-select-nvim;
    type = "lua";
    config = /*lua*/ ''
      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    '';
  };
in {
  imports = [
    ./fzf-native.nix
    ./live-grep-args.nix
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.telescope-nvim;
      type = "lua";
      config = /*lua*/ ''
        require('telescope').setup {
          extensions = {
            ["ui-select"] = {
              require("telescope.themes").get_dropdown {}
            },
          },
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
      my-telescope-ui-select-nvim
    ];
  };
}
