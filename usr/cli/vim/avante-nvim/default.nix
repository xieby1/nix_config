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
# - Copilot uses more premium request credits: https://github.com/yetone/avante.nvim/issues/2989
{ config, pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.pkgsu.vimPlugins.avante-nvim.overrideAttrs (old: {
      # Avante receives ACP available_commands_update events, but currently only
      # copies them into Config.slash_commands inside an nvim-cmp-only branch.
      # Move that state update outside the cmp guard so blink-cmp-avante can read
      # ACP slash commands from require("avante.utils").get_commands().
      patches = (old.patches or []) ++ [ ./acp-slash-commands-for-blink.patch ];
    });
    type = "lua";
    config = /*lua*/''
      require("avante").setup({
        -- this file can contain specific instructions for your project
        -- instructions_file = "avante.md",
        -- for example
        provider = "goose-${config.ai.jw-codex.id}",
        acp_providers = {
          ["goose-${config.ai.jw-codex.id}"] = {
            command = "goose-${config.ai.jw-codex.id}",
            args = {"acp"},
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
  home.shellAliases.avante=''nvim -c "lua vim.defer_fn(function()require(\"avante.api\").ask({ new_chat = true })end, 100)"'';
}
