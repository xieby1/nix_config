{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-navic;
      type = "lua";
      config = ''
        require("nvim-navic").setup {
          lsp = {
            auto_attach = true,
          },
        }
      '';
    }{
      plugin = pkgs.vimPlugins.nvim-navbuddy;
      type = "lua";
      config = ''
        require("nvim-navbuddy").setup {
          lsp = {
            auto_attach = true,
          },
          mappings = {
            ["<S-Tab>"] = require("nvim-navbuddy.actions").parent(),
            ["<Tab>"]   = require("nvim-navbuddy.actions").children(),
          },
        }
      '';
    }];
  };
}

