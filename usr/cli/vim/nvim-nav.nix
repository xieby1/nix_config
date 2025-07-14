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
        -- https://unix.stackexchange.com/questions/224771/what-is-the-format-of-the-default-statusline
        -- %<%f %h%w%m%r%=%-14.(%l,%c%V%) %P
        vim.o.statusline = "%<%f %h%w%m%r " ..
          -- set maximum width of nvim-navic str: winwidth-40
          -- exec %{%...%} results in '%.xx(yyyy%)', where xx is the max width, yyyy is the navic str
          "%{%'%.' .. (winwidth(0)-40) .. '(' .. v:lua.require'nvim-navic'.get_location() .. '%)'%}" ..
          " %=%-8.(%l,%c%) %P"
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

