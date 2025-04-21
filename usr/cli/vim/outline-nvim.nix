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
          guides = {
            enabled = false, -- I already have mini indentscope
          },
          symbol_folding = {
            autofold_depth = 99,
          },
          keymaps = {
            close = {}, -- disable close key
          },
        })
      '';
    }];
  };
}
