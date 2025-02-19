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
      postPatch = ''
        substituteInPlace lua/codecompanion/strategies/chat/ui.lua \
          --replace-fail "vsplit" "vertical topleft new"
      '';
      meta.homepage = "https://github.com/olimorris/codecompanion.nvim/";
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
            diff = {
              enabled = true,
            },
          },
        },
        strategies = {
          chat = {
            adapter = "deepseek",
          },
          inline = {
            adapter = "deepseek",
          },
        },
      })
    '';
  }];
}
