{ d2-src, veryl-src, merman-src }: # local-args
#MC # nvim-treesitter: languages parsing
{ pkgs, ... }: let
  mermaid-src = merman-src + "/distribution/tree-sitter-mermaid";
in {
  programs.neovim = {
    plugins = [{
      # Available languages see:
      #   https://github.com/nvim-treesitter/nvim-treesitter
      # see `pkgs.tree-sitter.builtGrammars.`
      # with `tree-sitter-` prefix and `-grammar` suffix removed
      plugin = (pkgs.vimPlugins.nvim-treesitter.withPlugins (_:
      (builtins.filter (grammar: grammar.language != "mermaid")
        pkgs.vimPlugins.nvim-treesitter.allGrammars) ++ [
        # The monaqa grammar is unmaintained and misparses continued flowchart edges.
        (pkgs.tree-sitter.buildGrammar {
          language = "mermaid";
          version = "0.3.5";
          src = mermaid-src;
        })
        #MC When edit a large d2 file using d2-vim, the cursor movement becomes lag.
        #MC However, tree-sitter-d2 works fluently.
        #MC So I replace the d2-vim with tree-sitter-d2.
        (pkgs.tree-sitter.buildGrammar {
          language = "d2";
          version = pkgs.lib.removePrefix "v" d2-src.version;
          src = d2-src;
        })
        (pkgs.tree-sitter.buildGrammar {
          language = "veryl";
          # Only checked against tree-sitter.json metadata, no functional impact
          version = "0.1.0";
          src = veryl-src;
        })
      ])).overrideAttrs (old: {
        # Merman's CST requires its own queries rather than monaqa's.
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/queries/mermaid
          cat ${mermaid-src}/queries/portable/highlights.scm \
            ${mermaid-src}/queries/neovim/highlights.scm \
            > $out/queries/mermaid/highlights.scm
          for query in folds indents injections; do
            cp ${mermaid-src}/queries/neovim/$query.scm \
              $out/queries/mermaid/$query.scm
          done
        '';
      });
      type = "lua";
      config = /*lua*/''
        vim.filetype.add({ extension = { mdx = "markdown", veryl = "veryl" } })
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
