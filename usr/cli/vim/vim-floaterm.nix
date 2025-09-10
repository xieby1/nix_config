#MC # vim-floaterm: floating terminal
{ pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.vim-floaterm;
    config = /*vim*/ ''
      nmap <Leader>t :FloatermNew --cwd=<buffer><CR>
      " let g:floaterm_keymap_new = '<Leader>t'
      let g:floaterm_width = 0.8
      let g:floaterm_height = 0.8
    '';
  }];
}
