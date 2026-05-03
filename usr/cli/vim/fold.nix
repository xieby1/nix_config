#MC # fold
{ ... }: {
  programs.neovim = {
    # TODO: rewrite in lua
    extraConfig = ''
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
    '';
    extraLuaConfig = /*lua*/''
      -- Decrease foldcolumn
      vim.keymap.set('n', 'z-', function()
        local value = tonumber(vim.o.foldcolumn) or 0
        if value > 0 then
          vim.o.foldcolumn = tostring(value - 1)
        end
      end, { desc = 'Decrease foldcolumn' })
      -- Increase foldcolumn
      vim.keymap.set('n', 'z=', function()
        local value = tonumber(vim.o.foldcolumn) or 0
        vim.o.foldcolumn = tostring(value + 1)
      end, { desc = 'Increase foldcolumn' })
    '';
  };
}
