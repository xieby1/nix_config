#MC # Code Companion: AI
{ lib, pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.codecompanion-nvim;
    type = "lua";
    # https://codecompanion.olimorris.dev/configuration/adapters.html
    config = /*lua*/ ''
      require("codecompanion").setup({
        adapters = {
          deepseek = function() return require("codecompanion.adapters").extend("deepseek", {
            env = { api_key = "cmd:cat ~/Gist/Vault/deepseek_api_key_nvim.txt" },
            schema = { model = { default = "deepseek-chat" } },
          }) end,
        },
        display = {
          chat = {
            window = {
              position = "left",
              width = 40,
            },
            diff = { enabled = true },
          },
        },
        strategies = {
          chat = { adapter = "deepseek" },
          inline = { adapter = "deepseek" },
        },
      })

      -- key bindings of AI
      vim.keymap.set('n', '<leader>a', ':CodeCompanionChat Toggle<CR>')
      vim.keymap.set('v', '<leader>a', ':CodeCompanionChat Add<CR>')
    '';
  }];
}
