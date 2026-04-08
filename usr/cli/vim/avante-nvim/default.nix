# TODO:
# - !!!: TLS error: it is a curl problem, which use the all_proxy env.
# - A better name for avante scatch buffer, for window search in wayland.
# - Move blink-cmp setting to here.
# - Outline.
# - Always show tokens consumption.
# - Enable language check in input scratch buffer.
# - Enable LSP.
# - start up with new session
# Pros:
# Cons:
# - Cannot change background?
# - Does not support notifications?
{ config, pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.pkgsu.vimPlugins.avante-nvim;
    type = "lua";
    config = /*lua*/''
      require("avante").setup({
        -- this file can contain specific instructions for your project
        -- instructions_file = "avante.md",
        -- for example
        provider = "minimax",
        providers = {
          deepseek = {
            __inherited_from = "openai",
            -- api_key_name = "DEEPSEEK_API_KEY",
            parse_api_key = function() return "${config.ai.deepseek.api_key}" end,
            endpoint = "${config.ai.deepseek.api_endpoint}",
            model = "deepseek-reasoner",
          },
          minimax = {
            __inherited_from = "claude",
            -- api_key_name = "DEEPSEEK_API_KEY",
            parse_api_key = function() return "${config.ai.minimax-china.api_key}" end,
            endpoint = "${config.ai.minimax-china.api_endpoint}",
            model = "MiniMax-M2.7",
          },
        },
        windows = {
          position = "left",
          ask = {
            start_insert = false,
          },
        },
      })
    '';
  }];
  programs.bash.shellAliases.avante=''nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'';
}
