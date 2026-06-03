{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.todo-comments-nvim;
      type = "lua";
      config = /*lua*/''
        require("todo-comments").setup({})

        vim.keymap.set("n", "]t", function()
          require("todo-comments").jump_next()
        end, { desc = "Next todo comment" })

        vim.keymap.set("n", "[t", function()
          require("todo-comments").jump_prev()
        end, { desc = "Previous todo comment" })
      '';
    }];
  };
}
