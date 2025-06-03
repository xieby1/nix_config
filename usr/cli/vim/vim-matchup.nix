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
      ''
      # * [Incompatibility with nvim-cmp snippet completion #328](Incompatibility with nvim-cmp snippet completion #328)
      # * [[Bug] Sniprun + matchup cause snippets to automatically be expanded in nvim-cmp #354](https://github.com/andymass/vim-matchup/issues/354)
      #   * [fix(*) incopatibility with blink-cmp as well as nvim-cmp #354 #382](https://github.com/andymass/vim-matchup/pull/382/files)
      + ''
        require('cmp').event:on("menu_opened", function()
          vim.b.matchup_matchparen_enabled = false
        end)
        require('cmp').event:on("menu_closed", function()
          vim.b.matchup_matchparen_enabled = true
        end)
      '';
    }];
  };
}
