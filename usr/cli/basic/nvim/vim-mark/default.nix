#MC # vim-mark: multi-color highlight
{ config, pkgs, stdenv, lib, ... }:
let
  vim-ingo-library = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ingo-library";
    src = pkgs.fetchFromGitHub {
      owner = "inkarkat";
      repo = "vim-ingo-library";
      rev = "c553c48f4ee14a70fd2dc7825bfe5aab91e50469";
      hash = "sha256-YjJYC56yr2+VvbVG1dsQYUGq2bmQMlOKABtdevuloGA=";
    };
  };
  my-vim-mark = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "vim-mark";
      # TODO: Place vim-mark's [current/total] at the exact same screen position as Neovim's native search counter.
      # Once UI2 is stable, consider using its search_cmd and search_count messages for native placement.
      patches = [ ./inline-search-count.patch ];
      src = pkgs.fetchFromGitHub {
        owner = "inkarkat";
        repo = "vim-mark";
        rev = "7b359ecab6e15721d690a6d1b98955e8bb0495de";
        hash = "sha256-moISQNNKzZGDM+XUD5mo7W2cWbZQaAZ1xtZ1ZjbfeuA=";
      };
    };
    type = "viml";
    config = ''
      " clear highlight created by vim-mark
      nnoremap <leader><F3> :MarkClear<CR>
      " show all marks
      nnoremap <leader>M :Marks<CR>
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-vim-mark
      vim-ingo-library
    ];
  };
}
