#MC # nvim-treesitter: languages parsing
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      # Available languages see:
      #   https://github.com/nvim-treesitter/nvim-treesitter
      # see `pkgs.tree-sitter.builtGrammars.`
      # with `tree-sitter-` prefix and `-grammar` suffix removed
      plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (_:
      pkgs.vimPlugins.nvim-treesitter.allGrammars ++ [
        #MC When edit a large d2 file using d2-vim, the cursor movement becomes lag.
        #MC However, tree-sitter-d2 works fluently.
        #MC So I replace the d2-vim with tree-sitter-d2.
        (pkgs.tree-sitter.buildGrammar {
          language = "d2";
          version = pkgs.lib.removePrefix "v" pkgs.npinsed.nvim.tree-sitter-d2.version;
          src = pkgs.npinsed.nvim.tree-sitter-d2;
        })
      ]);
      type = "lua";
      config = /*lua*/''
        vim.filetype.add({ extension = { mdx = "markdown" } })
        vim.api.nvim_create_autocmd('FileType', {
          callback = function(ev)
            local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
            if lang and vim.treesitter.language.add(lang) then
              vim.treesitter.start(ev.buf, lang)
            end
          end,
        })
      '';
    }];
  };
}
