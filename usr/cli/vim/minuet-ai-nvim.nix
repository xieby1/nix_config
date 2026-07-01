{ config, pkgs, lib, ... }: {
  # mkAfter makes sure statusline setting is after nvim-nav.nix
  programs.neovim.plugins = lib.mkAfter [pkgs.vimPlugins.plenary-nvim {
    plugin = pkgs.vimPlugins.minuet-ai-nvim;
    type = "lua";
    config = /*lua*/ ''
      require('minuet').setup {
        -- Disable auto complete, only trigger minuet manually
        blink = { enable_auto_complete = false },
        -- FIM is usually better for completion;
        -- use Claude here because MiniMax's Anthropic API works better.
        provider = 'openai_fim_compatible',
        provider_options = {
          openai_fim_compatible = {
            api_key = function() return '${config.ai.deepseek.api_key}' end,
            api_key = 'DEEPSEEK_API_KEY',
            name = 'deepseek',
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
        },
      }

      function update_minuet_statusline()
        local minuet = require("minuet")
        vim.o.statusline = string.gsub(vim.o.statusline, "[ᯤ]*$",
          minuet.config.blink.enable_auto_complete and "ᯤ" or "")
      end
      vim.keymap.set({'n','i'}, '<S-A-a>', function()
        local minuet = require("minuet")
        minuet.config.blink.enable_auto_complete = not minuet.config.blink.enable_auto_complete
        update_minuet_statusline()
      end)
      update_minuet_statusline()
    '';
  }];
}
