#MC # Code Companion: AI
{ pkgs, config, ... }: {
  programs.neovim.plugins = [
    pkgs.pkgsu.vimPlugins.codecompanion-history-nvim
  {
    plugin = pkgs.pkgsu.vimPlugins.codecompanion-nvim;
    type = "lua";
    # https://codecompanion.olimorris.dev/configuration/adapters.html
    config = /*lua*/ ''
      -- codecompanion does not support call setup multiple times, I have tried, see 28de5b86.
      -- If include history.nix with second setup, codecompanion cannot use history.
      require("codecompanion").setup({
        adapters = {
          http = {
            deepseek = function() return require("codecompanion.adapters").extend("deepseek", {
              env = { api_key = "${config.ai.deepseek.api_key}" },
              schema = {
                model = {
                  choices = {
                    -- The codecompanion-nvim default deepseek-reasoner cannot use tools, only deepseek-chat can
                    -- So override the setting here, to enable deepseek-reasoner can_use_tools.
                    ["deepseek-reasoner"] = { opts = { can_reason = true, can_use_tools = true } },
                  },
                },
              },
            }) end,
            -- By crush+copilot(claude opus4.6)
            -- ## Root Cause (updated)
            -- Setting `available_tools = {}` in `extend()` doesn't work because `vim.tbl_deep_extend` merges recursively. The Anthropic adapter's `available_tools` (containing `web_search`, `web_fetch`, `code_execution`, `memory`) **survives the merge**. So MiniMax still receives the Anthropic-proprietary `web_search_20250305` tool format, which it can't parse.
            -- ## Fix
            -- You need to set `available_tools` **after** the extend call. Change your config to:
            minimax = function()
              local adapter = require("codecompanion.adapters").extend("anthropic", {
                name = "minimax",
                formatted_name = "MiniMax",
                url = "${config.ai.minimax-china.api_endpoint}/v1/messages",
                env = { api_key = "${config.ai.minimax-china.api_key}" },
                schema = {
                  model = {
                    default = "${config.ai.minimax-china.default_large_model_id}",
                    choices = {
                      ["${config.ai.minimax-china.default_large_model_id}"] = { opts = { can_reason = true, has_token_efficient_tools = true } },
                      ["${config.ai.minimax-china.default_small_model_id}"] = { opts = { can_reason = true, has_token_efficient_tools = true } },
                    },
                  },
                }
              })
              adapter.available_tools = {}
              return adapter
            end,
          },
          acp = {
            pi = function()
              return require("codecompanion.adapters").extend("opencode", {
                name = "pi",
                formatted_name = "Pi",
                commands = { default = { "pi-acp", }, },
              })
            end,
          },
        },
        display = {
          chat = {
            window = {
              position = "left",
              width = 40,
              -- call api.nvim_set_option_value(k, v, { scope = "local", win = winnr }) for each k,v in opts
              opts = {
                winfixwidth = true,
              },
            },
            diff = { enabled = true },
            fold_reasoning = false,
            -- Adapter can't be changed when `display.chat.show_settings = true`
            -- Fine!
            -- show_settings = true,
          },
        },
        strategies = {
          chat = {
            adapter = "pi",
            tools = {
              opts = {
                default_tools = { "agent" },
              },
            },
          },
          inline = { adapter = "pi", },
        },
        extensions = {
          -- TODO: move extensions config to separate file
          history = {
            enabled = true,
            opts = {
              auto_generate_title = false;
            },
          }
        }
      })

      -- key bindings of AI
      vim.keymap.set('n', '<leader>a', ':CodeCompanionChat Toggle<CR>')
      vim.keymap.set('v', '<leader>a', ':CodeCompanionChat Add<CR>')
    '';
  }];

  programs.bash.shellAliases.codecompanion=''nvim -c CodeCompanionChat -c "bd 1" -c Outline!'';
}
