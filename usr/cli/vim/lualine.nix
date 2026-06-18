{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.lualine-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("lualine").setup({
          sections = {
            lualine_x = {'filetype'},
          },
        })
      '';
    }];
  };
}
