{ config, pkgs, lib, ... }: let
  api_key_file = "${config.home.homeDirectory}/Gist/Vault/siliconflow_api_key_chatbox.txt";
in { config = lib.mkIf (builtins.pathExists api_key_file) {
  # mkAfter makes sure statusline setting is after nvim-nav.nix
  programs.neovim.plugins = lib.mkAfter [pkgs.vimPlugins.plenary-nvim {
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
          --[[
            Enable ollama:
            * ollama serve
            * ollama pull qwen2.5-coder:0.5b
            * or other model support completion and insert capabilities
              (I dont why need insert, and the ollama docs and minuet-ai-nvim docs don't explain about this)
          ]]
          -- openai_fim_compatible = {
          --   model = "qwen2.5-coder:0.5b",
          --   end_point = "localhost:11434/v1/completions",
          --   name = "Qwen2.5",
          --   stream = true,
          --   api_key = 'TERM',
          --   optional = {
          --     max_tokens = 5,
          --   },
          -- },
        },
        --context_window = 512,
      }

      function update_minuet_statusline()
        local minuet = require("minuet")
        vim.o.statusline = string.gsub(vim.o.statusline, "[ᯤ]*$",
          minuet.config.blink.enable_auto_complete and "ᯤ" or "")
      end
      vim.keymap.set({'n','i'}, '<A-a>', function() 
        local minuet = require("minuet")
        minuet.config.blink.enable_auto_complete = not minuet.config.blink.enable_auto_complete
        update_minuet_statusline()
      end)
      update_minuet_statusline()
    '';
  }];
};}
