{ ... }: {
  programs.neovim.extraLuaConfig = /*lua*/''
    vim.keymap.set('n', '<leader>t', function()
      -- Get the current file's directory, falling back to cwd for unnamed buffers
      local dir
      if vim.bo.buftype == 'terminal' then
        -- In a terminal buffer: use the current working directory
        dir = vim.fn.getcwd()
      else
        local file = vim.api.nvim_buf_get_name(0)
        dir = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
      end

      -- Create a new empty split (equivalent to :horizontal terminal's split behavior)
      vim.cmd('horizontal new')

      -- NOTE: jobstart() must receive a *list* ({vim.o.shell}) rather than a
      -- string (vim.o.shell) for the default Neovim auto-close to work.
      --
      -- Neovim's built-in TermClose autocmd (nvim.terminal group) only
      -- auto-deletes terminal buffers when exit status is 0 AND argv exactly
      -- matches vim.o.shell. With a string, jobstart wraps it as:
      --   [sh, -c, bash]
      -- so table.concat(argv, ' ') becomes "sh -c bash", which does NOT
      -- equal vim.o.shell. With a list, argv is exactly ["bash"], which
      -- matches and triggers auto-close. See defaults.lua:576-590 and
      -- vimfn.txt:5467-5471.
      vim.fn.jobstart({vim.o.shell}, {
        term = true,
        cwd = dir,
      })

      vim.cmd('startinsert')
    end)
    vim.keymap.set('n', '<leader>T', function()
      vim.cmd('horizontal new')
      vim.fn.jobstart({vim.o.shell}, {
        term = true,
      })
      vim.cmd('startinsert')
    end)

    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
  '';
}
