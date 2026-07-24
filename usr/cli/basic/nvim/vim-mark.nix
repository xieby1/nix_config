#MC # vim-mark: multi-color highlight
{ config, pkgs, stdenv, lib, ... }:
let
  vim-ingo-library = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ingo-library";
    src = pkgs.fetchFromGitHub {
      owner = "inkarkat";
      repo = "vim-ingo-library";
      rev = "c93c33f803356b16bf4b4d122404d8251dc7b24d";
      hash = "sha256-85h3S+5IjVIbTkYJasPXU+z/ALc9oT+MzdyjvTOhIwg=";
    };
  };
  my-vim-mark = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "vim-mark";
      src = pkgs.fetchFromGitHub {
        owner = "inkarkat";
        repo = "vim-mark";
        rev = "76a25085d7c46f90fd5dfd7c43c3ba05b86ee192";
        hash = "sha256-h2uaZ8dCUopNJ7fpf3BEoZNRk+25zqFukcHa3LomPSk=";
      };
    };
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
