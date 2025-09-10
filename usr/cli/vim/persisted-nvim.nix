#MC # persisted sessions management
#MC
#MC persisted.nvim vs persistence-nvim
#MC
#MC * persisted-nvim support telescope, while persistence-nvim not
{ pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.persisted-nvim;
    type = "lua";
    config = /*lua*/ ''
      require("persisted").setup({
        telescope = {
          mappings = { -- Mappings for managing sessions in Telescope
            copy_session = "<C-v>",
            change_branch = "<C-b>",
            delete_session = "<S-Del>",
          },
        },
      })
      require("telescope").load_extension("persisted")
      vim.api.nvim_create_user_command("Session", "Telescope persisted", {})
    '';
  }];
}
