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
        (pkgs.tree-sitter.buildGrammar rec {
          language = "d2";
          # tree-sitter language version 14
          version = "0.5.1";
          src = pkgs.fetchFromGitHub {
            owner = "ravsii";
            repo = "tree-sitter-d2";
            rev = "v${version}";
            hash = "sha256-Ru+EAtnBl+Td4HxHPXLwcXOiFB/NbYPE5AhMNFyP2Kg=";
          };
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
