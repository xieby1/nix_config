{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.todo-comments-nvim;
      type = "lua";
      config = /*lua*/''
        require("todo-comments").setup({
          keywords = {
            EUREKA = { icon = "🤓", },
            TODO = { icon = "☐ ", color = "info" },
            DONE = { icon = " " },
          },
          highlight = {
            multiline = false,
            before = "",
            after = "",
            -- Use non-greedy .{-} so the first keyword wins when a line contains multiple keywords.
            pattern = [=[.{-}<(KEYWORDS)\s*[:：]]=],
            comments_only = false,
          },
        })

        vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo comment" })
        vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo comment" })
        vim.keymap.set("n", "<space>t", function () Snacks.picker.todo_comments({ keywords = { "TODO" } }) end, { desc = "only TODO keyword" })
        vim.keymap.set("n", "<space>T", function () Snacks.picker.todo_comments() end, { desc = "all todo-comments supported keywords" })
      '';
    }];
  };
}
