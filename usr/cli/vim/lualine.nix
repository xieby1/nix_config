{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.lualine-nvim.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ./lualine-show-identical-bg-section-separators.patch
        ];
      });
      type = "lua";
      config = /*lua*/ ''
        require("lualine").setup({
          options = {
            theme = (function()
              local function hl(name)
                local highlight = vim.api.nvim_get_hl(0, { name = name })
                return {
                  fg = highlight.fg and string.format("#%06x", highlight.fg) or nil,
                  bg = highlight.bg and string.format("#%06x", highlight.bg) or nil,
                  gui = highlight.bold and "bold" or nil,
                }
              end

              local active = hl("StatusLine")
              local inactive = hl("StatusLineNC")

              return {
                normal =   { a =   active, b =   active, c =   active },
                insert =   { a =   active, b =   active, c =   active },
                visual =   { a =   active, b =   active, c =   active },
                replace =  { a =   active, b =   active, c =   active },
                command =  { a =   active, b =   active, c =   active },
                inactive = { a = inactive, b = inactive, c = inactive },
              }
            end)(),
            component_separators = { left = "", right = ""},
            section_separators = { left = '┇', right = '┇'},
          },
          sections = {
            lualine_a = { {'filename', path = 1 --[[relative path]],}, },
            lualine_b = {'branch', 'diagnostics'},
            lualine_c = {
              function() return require('nvim-navic').get_location() end,
            },
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
