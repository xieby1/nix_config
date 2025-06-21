#MC # Code Companion: AI
{ lib, pkgs, ... }: {
  #MC Q: Why `mkAfter` here?
  #MC
  #MC A: As codecompanion will change the nvim-cmp config,
  #MC therefore we need to make codecompanion is setup after nvim-cmp.
  #MC Use `mkAfter`, make config of codecompanion is placed after all
  #MC other normal configs in `~/.config/nvim/init.lua`.
  programs.neovim.plugins = lib.mkAfter [{
    plugin = pkgs.vimUtils.buildVimPlugin {
      pname = "codecompanion.nvim";
      # currently lastest
      version = "2025-1-27";
      src = pkgs.fetchFromGitHub {
        owner = "olimorris";
        repo = "codecompanion.nvim";
        rev = "f8b9dce0468708c3b280abb045927c6864a17869";
        hash = "sha256-1EMzh3TaQxj+eMLjizHwntl/6ZqTHRlxFF6IOSROnuA=";
      };
      # vertical split current window (including multiple buffers), instead of vsplit current buffer
      postPatch = ''
        substituteInPlace lua/codecompanion/strategies/chat/ui.lua \
          --replace-fail "vsplit" "vertical topleft new"
      ''
      # fix the chat window
      + ''
        sed -i '/ui.set_win_options/i vim.cmd("set winfixwidth")' lua/codecompanion/strategies/chat/ui.lua
      ''
      #MC Use telescope as selection provider.
      #MC Though it can be configured like, each slash_commands needs to be configured, which is very cumbersome!
      #MC
      #MC ```lua
      #MC strategies = {
      #MC   chat = {
      #MC     slash_commands = {
      #MC       ["file"] = {
      #MC         callback = "strategies.chat.slash_commands.file",
      #MC         description = "Select a file using Telescope",
      #MC         opts = {
      #MC           provider = "telescope",
      #MC           contains_code = true,
      #MC         },
      #MC       },
      #MC       ["buffer"] = {...}
      #MC     },
      #MC   },
      #MC },
      #MC ```
      #MC
      #MC So I decided to replace all the provider in source code like below:
      + ''
        sed -i 's/provider = .*telescope.*/provider = "telescope",/' lua/codecompanion/config.lua
      '';
      meta.homepage = "https://github.com/olimorris/codecompanion.nvim/";
      doCheck = false;
    };
    type = "lua";
    # https://codecompanion.olimorris.dev/configuration/adapters.html
    config = ''
      require("codecompanion").setup({
        adapters = {
          deepseek = function()
            return require("codecompanion.adapters").extend("deepseek", {
              env = {
                api_key = "cmd:cat ~/Gist/Vault/deepseek_api_key_nvim.txt",
              },
              schema = {
                model = {
                  default = "deepseek-chat",
                },
              },
            })
          end,
        },
        display = {
          chat = {
            window = {
              width = 40,
            },
            diff = {
              enabled = true,
            },
          },
        },
        strategies = {
          chat = {
            adapter = "deepseek",
            slash_commands = {
              ["file"] = {
                callback = "strategies.chat.slash_commands.file",
                description = "Select a file using Telescope",
                opts = {
                  provider = "telescope",
                  contains_code = true,
                },
              },
            },
          },
          inline = {
            adapter = "deepseek",
          },
        },
      })

      -- key bindings of AI
      vim.keymap.set('n', '<leader>a', ':CodeCompanionChat Toggle<CR>')
      vim.keymap.set('v', '<leader>a', ':CodeCompanionChat Add<CR>')
    '';
  }];
}
