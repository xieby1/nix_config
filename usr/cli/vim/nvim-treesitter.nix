#MC # nvim-treesitter: languages parsing
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      # Available languages see:
      #   https://github.com/nvim-treesitter/nvim-treesitter
      # see `pkgs.tree-sitter.builtGrammars.`
      # with `tree-sitter-` prefix and `-grammar` suffix removed
      plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (tree-sitter: [
        tree-sitter.c
        tree-sitter.cpp
        tree-sitter.python
        tree-sitter.markdown
        tree-sitter.lua
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
      config = ''
        require 'nvim-treesitter.configs'.setup {
          -- TODO: https://github.com/NixOS/nixpkgs/issues/189838
          -- ensure_installed = {"c", "cpp", "python", "markdown"},
          ensure_installed = {},
          sync_install = false,
          highlight = {
            enable = true,
          },
        }
      '';
    }];
  };
}
