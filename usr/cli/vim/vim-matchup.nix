{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.vim-matchup;
      type = "lua";
      config = ''
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
        -- 不要加粗光标下的可匹配文字，不然写代码时常遇到的不协调感觉
        -- 比如写{}时{是普通字体}是加粗字体，光标左移一下，{变成加粗}是普通字体。
        vim.cmd("highlight MatchParenCur cterm=NONE gui=NONE")
      '';
    }];
  };
}
