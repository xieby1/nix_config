{ config, pkgs, stdenv, lib, ... }: {
  #MC Plugins with customizations:
  imports = [
    ./fold.nix
    ./conform-nvim.nix
    ./nvim-lspconfig
    ./blink-cmp.nix
    ./vim-mark.nix
    ./nvim-treesitter.nix
    ./nvim-config-local.nix
    ./leap-nvim.nix
    ./telescope-nvim.nix
    ./git-wip.nix
    ./vim-floaterm.nix
    ./outline-nvim.nix
    ./vim-hexokinase.nix
    ./gitsigns-nvim.nix
    ./color-scheme.nix
    ./hbac-nvim.nix
    ./winshift-nvim.nix
    ./smartyank-nvim.nix
    ./mini-nvim.nix
    ./vim-easy-align.nix
    ./codecompanion-nvim.nix
    ./close-windows.nix
    ./nvim-window-picker.nix
    ./vim-matchup.nix
    ./nvim-nav.nix
    ./markdown-preview-nvim.nix
    ./venn-nvim.nix
    ./snacks-nvim.nix
    ./minuet-ai-nvim.nix
    ./auto-session.nix
    ./nvim-treesitter-context.nix
  ];

  programs.bash.shellAliases.view = "nvim -R";
  #MC Set nvim as manpager.
  #MC see nvim `:h :Man`.
  #MC nvim manpage huge mange is SLOW! E.g. man configuration.nix.
  programs.bash.shellAliases.nman = "env MANPAGER='nvim +Man!' man";

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    #MC Plugins without customizations:
    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      vim-nix
      vim-markdown-toc
      vim-commentary
      vim-surround
      otter-nvim
    ];

    #MC Vim config
    extraConfig = /*vim*/ ''
      " vim
      "" Highlight searches
      set hlsearch
      nnoremap <F3> :nohlsearch<CR>
      "" Show line number
      set number
      "" Always show the signcolumn, otherwise it would shift the text each time
      "" diagnostics appear/become resolved
      set signcolumn=number
      "" indent
      """ On pressing tab, insert spaces
      set expandtab
      """ no markdown recommended indent style (recommended shiftwidth=4)
      let g:markdown_recommended_style = 0
      """ line wrap with ident
      set breakindent

      """ mouse support " select by pressing shift key!
      set mouse=a
      "" Preview
      nnoremap <leader>[ :pc<CR>
      "" highlight unwanted whitespace
      set list
      set listchars=tab:>-,trail:-
      "" syntax
      syntax on
      "" backspace
      set backspace=indent,eol,start
      "" wrap line
      """ https://stackoverflow.com/questions/248102/is-there-any-command-to-toggle-enable-auto-text-wrapping
      :function ToggleWrap()
      : if (&wrap == 1)
      :   set nowrap
      : else
      :   set wrap
      : endif
      :endfunction
      nnoremap <F9> :call ToggleWrap()<CR>
      set updatetime=400
      "" highlight current line
      set cursorlineopt=number
      augroup CursorLine
        au!
        au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
        au WinLeave * setlocal nocursorline
      augroup END

      " filetype
      augroup filetype
          " detect LLVM IR file
          au! BufRead,BufNewFile *.ll     set filetype=llvm
          " cpp " from gem5
          au! BufRead,BufNewFile *.hh.inc,*.cc.inc set filetype=cpp
          " d2
          au! BufRead,BufNewFile *.d2 set filetype=d2
          au! FileType d2 setlocal commentstring=#\ %s
      augroup END

      " set terminal title
      "" https://stackoverflow.com/questions/15123477/tmux-tabs-with-name-of-file-open-in-vim
      autocmd BufEnter * let &titlestring = "" . expand("%:t")
      set title

      nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

      " highlight
      augroup HiglightTODO
          autocmd!
          autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'TODO', -1)
      augroup END

      " TODO: replace wildmenu with blink-cmp cmdline
      " wildmenu
      " see: https://github.com/neovim/neovim/pull/11001
      cnoremap <expr> <Up>    pumvisible() ? "\<Left>"  : "\<Up>"
      cnoremap <expr> <Down>  pumvisible() ? "\<Right>" : "\<Down>"
      cnoremap <expr> <Left>  pumvisible() ? "\<Up>"    : "\<Left>"
      cnoremap <expr> <Right> pumvisible() ? "\<Down>"  : "\<Right>"

      " prevent resizing other windows when splitting/closing a window
      set noequalalways
      nnoremap <C-W><C-Left>  <C-W><Left>
      nnoremap <C-W><C-Right> <C-W><Right>
      nnoremap <C-W><C-Up>    <C-W><Up>
      nnoremap <C-W><C-Down>  <C-W><Down>
    '';
  };
}
