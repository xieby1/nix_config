#MC # avante-nvim: AI
#MC
#MC 2025.1.27：使用中发现的问题：
#MC * 没有:h
#MC * 说了要去掉nui但仍然没有https://news.ycombinator.com/item?id=41353835
#MC * 安装了dressing、nui、plenary（telescope都没问题）插件仍然不识别
#MC   ```vim
#MC   avante: require("avante.health").check()
#MC
#MC   avante.nvim ~
#MC   - ERROR Missing required plugin: stevearc/dressing.nvim
#MC   - ERROR Missing required plugin: MunifTanjim/nui.nvim
#MC   - ERROR Missing required plugin: nvim-lua/plenary.nvim
#MC   - OK Found required plugin: nvim-treesitter/nvim-treesitter
#MC   - OK Found icons plugin (nvim-web-devicons or mini.icons)
#MC   ```
#MC   简单看了代码avante checkhealth：lua/avante/utils/init.lua
#MC   居然要使用lazy。按claude.ai的说法
#MC   “啊,这是实际的源码实现,比我之前解释的要简单很多。让我详细解释一下这个函数:”
#MC   是不是就是因为简单，但是又没有强制要求安装lazy，遇到的问题？
{ lib, pkgs, ... }:
{
  programs.neovim = {
    plugins = with pkgs.pkgsu.vimPlugins; (lib.mkAfter [
      nui-nvim
      dressing-nvim
      {
        plugin = avante-nvim;
        type = "lua";
        config = ''
          require('avante_lib').load()
          require('avante').setup ({
            provider = "deepseek",
            vendors = {
              deepseek = {
                __inherited_from = "openai",
                api_key_name = "DEEPSEEK_API_KEY",
                endpoint = "https://api.deepseek.com",
                model = "deepseek-chat",
              },
            },
          })
        '';
      }
    ]);
  };
}
