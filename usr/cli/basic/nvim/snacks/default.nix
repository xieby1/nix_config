{ pkgs, ... }: {
  imports = [
    ./image/config.nix
    ./picker/config.nix
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("snacks").setup({
          ${import ./image/lua.nix}
          ${import ./scroll/lua.nix}
          ${import ./picker/lua.nix}
        })

        -- by hermes + claude opus 4.6
        vim.api.nvim_create_user_command("SnacksToggleImage", function()
          local cfg = Snacks.image.config
          cfg.enabled = not cfg.enabled
          if not cfg.enabled then
            Snacks.image.placement.clean()
            -- Stop inline/doc autocmds so images don't get re-created
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.b[buf].snacks_image_attached then
                pcall(vim.api.nvim_del_augroup_by_name, "snacks.image.inline." .. buf)
                pcall(vim.api.nvim_del_augroup_by_name, "snacks.image.doc." .. buf)
                vim.b[buf].snacks_image_attached = nil
              end
            end
          else
            -- Re-attach doc images for current buffer
            Snacks.image.doc.attach(vim.api.nvim_get_current_buf())
          end
          vim.notify("snacks.image: " .. (cfg.enabled and "enabled" or "disabled"))
        end, {})
      '';
    }];
  };
}
