{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.lualine-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("lualine").setup({
          options = {
            -- make the inactive theme same as active theme
            theme = (function()
              local t = require("lualine.themes.auto")
              t.inactive = {
                a = t.normal.a,
                b = t.normal.b,
                c = t.normal.c,
              }
              return t
            end)(),
          },
          sections = {
            lualine_a = {'filename'},
            lualine_b = {'branch', 'diagnostics'},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {'filetype'},
            lualine_z = {'location', 'progress'}
          },
          inactive_sections = {
            lualine_a = {'filename'},
            lualine_b = {'branch', 'diagnostics'},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {'filetype'},
            lualine_z = {'location', 'progress'}
          },
        })
      '';
    }];
  };
}
