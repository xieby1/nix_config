{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.telescope-fzf-native-nvim;
      type = "lua";
      config = /*lua*/ ''
        require('telescope').load_extension('fzf')
      '';
    }];
  };
}
