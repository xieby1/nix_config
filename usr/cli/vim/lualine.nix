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
        local inactive_sections = {
          lualine_a = { {'filename', path = 1 --[[relative path]],}, },
          lualine_b = {'branch', 'diagnostics'},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {'filetype'},
          lualine_z = {'location', 'progress'},
        }

        local sections = vim.tbl_extend('force', inactive_sections, {
          lualine_c = {
            function() return require('nvim-navic').get_location() end,
            { -- TODO: move it to codecompanion nix script
              function()
                local chat_metadata = _G.codecompanion_chat_metadata[vim.api.nvim_get_current_buf()]
                if not chat_metadata then
                  return ""
                end

                local adapter = chat_metadata.adapter or {}
                local parts = { adapter.name or "CodeCompanion" }
                if adapter.model then
                  table.insert(parts, adapter.model)
                end
                if chat_metadata.tokens and chat_metadata.tokens ~= 0 then
                  table.insert(parts, tostring(chat_metadata.tokens) .. " tokens")
                end
                if chat_metadata.tools and chat_metadata.tools ~= 0 then
                  table.insert(parts, tostring(chat_metadata.tools) .. " tools")
                end

                return "󰚩 " .. table.concat(parts, " · ")
              end,
              cond = function()
                return vim.bo.filetype == "codecompanion" and _G.codecompanion_chat_metadata ~= nil
              end,
            },
          },
        })

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
          inactive_sections = inactive_sections,
          sections = sections,
        })
      '';
    }];
  };
}
