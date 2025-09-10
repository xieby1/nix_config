{ config, pkgs, lib, ... }: let
  api_key_file = "${config.home.homeDirectory}/Gist/Vault/siliconflow_api_key_chatbox.txt";
in { config = lib.mkIf (builtins.pathExists api_key_file) {
  programs.neovim.plugins = [pkgs.vimPlugins.plenary-nvim {
    plugin = pkgs.vimPlugins.minuet-ai-nvim;
    type = "lua";
    config = /*lua*/ ''
      require('minuet').setup {
        provider = 'openai_fim_compatible',
        provider_options = {
          openai_fim_compatible = {
            name = 'Qwen',
            end_point = 'https://api.siliconflow.cn/v1/completions',
            api_key = function() return '${lib.fileContents api_key_file}' end,
            model = "Qwen/Qwen3-Coder-30B-A3B-Instruct",
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
        },
      }
    '';
  }];
};}
