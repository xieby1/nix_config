{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-treesitter-context;
      type = "lua";
      config = /*lua*/ ''
        require'treesitter-context'.setup{}
        vim.cmd("hi TreesitterContextBottom gui=underline guisp=Grey")
        vim.cmd("hi link TreesitterContext NONE")
      '';
    }];
  };
}
