{ config, pkgs, stdenv, lib, ... }:

let
  my-vim-floaterm = {
    plugin = pkgs.vimPlugins.vim-floaterm;
    config = ''
      nmap <Leader>t :FloatermNew --cwd=<buffer><CR>
      " let g:floaterm_keymap_new = '<Leader>t'
      let g:floaterm_width = 0.8
      let g:floaterm_height = 0.8
      " Set floaterm window's background
      hi Floaterm guibg=black
    '';
  };
  my-vista-vim = {
    plugin = pkgs.vimPlugins.vista-vim;
    config = ''
      let g:vista_default_executive = 'nvim_lsp'
    '';
  };
  my-vim-markdown = {
    plugin = pkgs.vimPlugins.vim-markdown;
    config = ''
      let g:vim_markdown_new_list_item_indent = 2
      let g:vim_markdown_no_default_key_mappings = 1
    '';
  };
  my-vim-hexokinase = {
    plugin = pkgs.vimPlugins.vim-hexokinase;
    config = ''
      let g:Hexokinase_highlighters = ['backgroundfull']
    '';
  };
  my-gitsigns-nvim = {
    plugin = pkgs.vimPlugins.gitsigns-nvim;
    type = "lua";
    config = ''
      require('gitsigns').setup {
        signcolumn = false,
        numhl      = true,
        linehl     = true,

        current_line_blame = true,

        -- keymaps
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
          map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line{full=true} end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    '';
  };
  my-color-scheme = {
    plugin = pkgs.vimPlugins.sonokai;
    config = ''
      nnoremap <leader>c :set termguicolors!<CR>
      set termguicolors

      let g:sonokai_transparent_background = 1

      let g:sonokai_colors_override = {
      \ 'black':    ['#111215', '237'],
      \ 'bg0':      ['#22232a', '235'],
      \ 'bg1':      ['#33353f', '236'],
      \ 'bg2':      ['#444754', '236'],
      \ 'bg3':      ['#555869', '237'],
      \ 'bg4':      ['#666a7e', '237'],
      \ 'grey':     ['#a5a5a6', '246'],
      \ 'grey_dim': ['#787879', '240'],
      \}

      " custom sonokai,
      " see section "How to use custom colors" of `:h sonokai.vim`
      function! s:sonokai_custom() abort
        let l:palette = sonokai#get_palette('default', {})
        call sonokai#highlight('StatusLine', l:palette.black, l:palette.fg, 'bold')
        call sonokai#highlight('StatusLineNC', l:palette.black, l:palette.grey, 'bold')
      endfunction
      augroup SonokaiCustom
        autocmd!
        autocmd ColorScheme sonokai call s:sonokai_custom()
      augroup END

      colorscheme sonokai
    '';
  };
  my-hbac = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "hbac.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "axkirillov";
        repo = "hbac.nvim";
        rev = "e2e8333aa56ef43a577ac3a2a2e87bdf2f0d4cbb";
        hash = "sha256-7+e+p+0zMHPJjpnKNkL7QQHZJGQ1DFZ6fsofcsVNXaY=";
      };
    };
    type = "lua";
    config = ''
      require("hbac").setup({
        autoclose     = true, -- set autoclose to false if you want to close manually
        threshold     = 10, -- hbac will start closing unedited buffers once that number is reached
        close_command = function(bufnr)
          vim.api.nvim_buf_delete(bufnr, {})
        end,
        close_buffers_with_windows = false, -- hbac will close buffers with associated windows if this option is `true`
        telescope = {
          -- See #telescope-configuration below
          },
      })
    '';
  };
  my-winshift-nvim = {
    plugin = pkgs.vimPlugins.winshift-nvim;
    type = "lua";
    config = ''
      -- Lua
      require("winshift").setup({
        highlight_moving_win = true,  -- Highlight the window being moved
        focused_hl_group = "Visual",  -- The highlight group used for the moving window
        -- moving_win_options = {
        --   -- These are local options applied to the moving window while it's
        --   -- being moved. They are unset when you leave Win-Move mode.
        --   wrap = true,
        --   cursorline = false,
        --   cursorcolumn = false,
        --   colorcolumn = "",
        -- },
        keymaps = {
          disable_defaults = false, -- Disable the default keymaps
          win_move_mode = {
            ["h"] = "left",
            ["j"] = "down",
            ["k"] = "up",
            ["l"] = "right",
            ["H"] = "far_left",
            ["J"] = "far_down",
            ["K"] = "far_up",
            ["L"] = "far_right",
            ["<left>"] = "left",
            ["<down>"] = "down",
            ["<up>"] = "up",
            ["<right>"] = "right",
            ["<S-left>"] = "far_left",
            ["<S-down>"] = "far_down",
            ["<S-up>"] = "far_up",
            ["<S-right>"] = "far_right",
          },
        },
        ---A function that should prompt the user to select a window.
        ---
        ---The window picker is used to select a window while swapping windows with
        ---`:WinShift swap`.
        ---@return integer? winid # Either the selected window ID, or `nil` to
        ---   indicate that the user cancelled / gave an invalid selection.
        window_picker = function()
          return require("winshift.lib").pick_window({
            -- A string of chars used as identifiers by the window picker.
            picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            filter_rules = {
              -- This table allows you to indicate to the window picker that a window
              -- should be ignored if its buffer matches any of the following criteria.
              cur_win = true, -- Filter out the current window
              floats = true,  -- Filter out floating windows
              filetype = {},  -- List of ignored file types
              buftype = {},   -- List of ignored buftypes
              bufname = {},   -- List of vim regex patterns matching ignored buffer names
            },
            ---A function used to filter the list of selectable windows.
            ---@param winids integer[] # The list of selectable window IDs.
            ---@return integer[] filtered # The filtered list of window IDs.
            filter_func = nil,
          })
        end,
      })

      vim.keymap.set('n', '<C-W>m', '<Cmd>WinShift<CR>')
    '';
  };
  my-smartyank-nvim = {
    plugin = pkgs.vimPlugins.smartyank-nvim;
    type = "lua";
    config = ''
      require('smartyank').setup {
        highlight = {
          enabled = false, -- not enable highlight yanked text
        },
        validate_yank = function() return vim.v.operator == '"+y' end,
      }
    '';
  };
  # mini-nvim is wonderful nvim plugin!
  # I found it due to below link:
  # indent-blankline.nvim is too complex.
  # However, it does not support basic functionality like highlight current indentation
  # See: https://github.com/lukas-reineke/indent-blankline.nvim/issues/649
  my-mini-nvim = {
    plugin = pkgs.vimPlugins.mini-nvim;
    type = "lua";
    config = ''
      require('mini.indentscope').setup{
        options = {
          try_as_border = true,
        },
      }

      -- mini.animate looks promising, and can totally replace vim-smoothie
      -- However, bugs seem exist:
      -- * touchpad scroll become slow
      -- * background color blinks when create window
      -- * background color broken after q::q
      -- require('mini.animate').setup()
    '';
  };
in
{
  imports = [
    ./nvim-metals
    ./conform-nvim.nix
    ./nvim-lspconfig.nix
    ./nvim-cmp.nix
    ./vim-mark.nix
    ./DrawIt.nix
    ./nvim-treesitter.nix
    ./nvim-config-local.nix
    ./leap-nvim.nix
    ./telescope-nvim.nix
    ./git-wip.nix
  ];

  # neovim
  programs.bash.shellAliases.view = "nvim -R";
  # nvim as manpager
  ## see nvim `:h :Man`
  ## nvim manpage huge mange is SLOW! E.g. man configuration.nix
  programs.bash.shellAliases.nman = "env MANPAGER='nvim +Man!' man";
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
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
      "set smartindent " not good, indentation in empty line cannot be auto removed
      """ show existing tab with 4 spaces width
      set tabstop=4
      """ when indenting with '>', use 4 spaces width
      set shiftwidth=4
      """ specicial indent
      au FileType markdown setlocal shiftwidth=2 tabstop=2
      """ On pressing tab, insert 4 spaces
      set expandtab
      """ line wrap with ident
      set breakindent
      """" horizontally scroll 4 characters
      nnoremap z<left> 4zh
      nnoremap z<right> 4zl
      "" tags support, ';' means upward search, refering to http://vimdoc.sourceforge.net/htmldoc/editing.html#file-searching
      set tags=./tags;
      "" Fold
      """ fold text to be the first and last line
      """ refer to sbernheim4's reply at
      """ https://github.com/nvim-treesitter/nvim-treesitter/pull/390
      function! GetSpaces(foldLevel)
          if &expandtab == 1
              " Indenting with spaces
              let str = repeat(" ", a:foldLevel / (&shiftwidth + 1) - 1)
              return str
          elseif &expandtab == 0
              " Indenting with tabs
              return repeat(" ", indent(v:foldstart) - (indent(v:foldstart) / &shiftwidth))
          endif
      endfunction
      function! MyFoldText()
          let startLineText = getline(v:foldstart)
          let endLineText = trim(getline(v:foldend))
          let indentation = GetSpaces(foldlevel("."))
          let spaces = repeat(" ", 200)
          let str = indentation . startLineText . " …… " . endLineText . spaces
          return str
      endfunction
      "" toggle foldmethod between manual and indent
      set foldmethod=indent
      :function ToggleFoldmethod()
      : if (&foldmethod == "manual")
      :   set foldmethod=indent
      : else
      :   set foldmethod=manual
      : endif
      :endfunction
      nnoremap <Leader>z :call ToggleFoldmethod()<CR>:echo &foldmethod<CR>
      "" Custom display for text when folding
      set foldtext=MyFoldText()
      """ Set the foldlevel to a high setting,
      """ files are always loaded with opened folds.
      set foldlevel=20
      """ mouse support " select by pressing shift key!
      set mouse=a
      """ matchit.vim " :h matchit-install
      packadd! matchit
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

      " wildmenu
      " see: https://github.com/neovim/neovim/pull/11001
      cnoremap <expr> <Up>    pumvisible() ? "\<Left>"  : "\<Up>"
      cnoremap <expr> <Down>  pumvisible() ? "\<Right>" : "\<Down>"
      cnoremap <expr> <Left>  pumvisible() ? "\<Up>"    : "\<Left>"
      cnoremap <expr> <Right> pumvisible() ? "\<Down>"  : "\<Right>"
    '';
    plugins = with pkgs.vimPlugins; [
      vim-smoothie
      vim-fugitive
      vim-nix
      my-vim-floaterm
      vim-markdown-toc
      my-vista-vim
      vim-commentary
      # javascript lsp support
      # coc-tsserver
      my-vim-markdown # format table
      tabular
      my-vim-hexokinase
      vim-plugin-AnsiEsc
      my-gitsigns-nvim
      my-color-scheme
      my-hbac
      my-winshift-nvim
      my-smartyank-nvim
      my-mini-nvim
    ] ++ (lib.optional config.isGui markdown-preview-nvim);
    vimdiffAlias = true;
  };
}
