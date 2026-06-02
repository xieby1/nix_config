{ pkgs, ... }: {
  imports = [
    ./fzf-native.nix
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
            mappings = {
              i = {
                -- freeze the current list and start a fuzzy search in the frozen list
                ["<C-space>"] = require("telescope.actions").to_fuzzy_refine,
                -- many terminals send Ctrl-Space as NUL / <C-@>
                ["<C-@>"] = require("telescope.actions").to_fuzzy_refine,
              },
            },
          },
        }
      '';
    }];
  };
}
