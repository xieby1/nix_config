{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.outline-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("outline").setup({
          -- Outline.nvim seems not support setup multiple times
          -- So I merge outline-treesitter-provider's config here
          providers = {
            -- append "treesitter" to original priority
            priority = (function() -- start of a local scope
              local original = require("outline.config").defaults.providers.priority
              table.insert(original, "treesitter")
              return original
            end)(), -- end of a local scope
          },
          outline_window = {
            relative_width = false,
          },
          guides = {
            enabled = false, -- I already have mini indentscope
          },
          symbol_folding = {
            autofold_depth = 99,
          },
          keymaps = {
            close = {}, -- disable close key
          },
        })
        vim.keymap.set('n', '<leader>o', require('outline').toggle)
      '';
    }(
      pkgs.vimUtils.buildVimPlugin {
        name = "outline-treesitter-provider.nvim";
        src = pkgs.npinsed.nvim.outline-treesitter-provider;
        doCheck = false;
      }
    )];
  };
}
