#MC # vim-mark: multi-color highlight
{ mark-src, ingo-src }: # local args
{ config, pkgs, stdenv, lib, ... }:
let
  vim-ingo-library = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ingo-library";
    src = ingo-src;
  };
  my-vim-mark = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "vim-mark";
      # TODO: Place vim-mark's [current/total] at the exact same screen position as Neovim's native search counter.
      # Once UI2 is stable, consider using its search_cmd and search_count messages for native placement.
      patches = [ ./inline-search-count.patch ];
      src = mark-src;
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
