{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-navic;
      type = "lua";
      config = ''
        require("nvim-navic").setup {
          lsp = {
            auto_attach = true,
            -- vue_ls forwards TypeScript requests to vtsls, so .vue buffers attach both.
            -- nvim-navic can use only one LSP per buffer; prefer vtsls to avoid warnings.
            preference = { "vtsls", "vue_ls" },
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

