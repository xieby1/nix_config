{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.todo-comments-nvim;
      type = "lua";
      config = /*lua*/''
        require("todo-comments").setup({})
      '';
    }];
  };
}
