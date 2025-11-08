{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.vim-matchup;
      type = "lua";
      config = /*lua*/ ''
        -- use nvim-treesitter-context to show match lines
        vim.g.matchup_matchparen_offscreen = {}
      '';
    }];
  };
}
