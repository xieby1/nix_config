{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.outline-nvim;
      type = "lua";
      config = ''
        require("outline").setup({
          outline_window = {
            relative_width = false,
          },
          symbol_folding = {
            autofold_depth = 99,
          },
        })
      '';
    }];
  };
}
