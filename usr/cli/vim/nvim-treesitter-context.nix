{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-treesitter-context;
      type = "lua";
      config = /*lua*/ ''
        require'treesitter-context'.setup({enable = false})
        vim.cmd("hi TreesitterContextBottom gui=underline guisp=Grey")
        vim.cmd("hi link TreesitterContext NONE")
        vim.keymap.set("n", "<leader>c", "<Cmd>TSContextToggle<CR>")
      '';
    }];
  };
}
