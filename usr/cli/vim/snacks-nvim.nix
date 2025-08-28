{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("snacks").setup({
          image = {
            enabled = true,
          },
        })
      '';
    }];
  };
}
