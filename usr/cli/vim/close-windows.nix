#MC # key bindings of closing windows
{ ... }: { programs.neovim.extraLuaConfig = /*lua*/ ''
  for Dir, cmd in pairs({Left="h", Down="j", Up="k", Right="l"}) do
    local f = function()
      local beg = vim.api.nvim_get_current_win()
      local cur
      while true do
        vim.api.nvim_set_current_win(beg)
        vim.cmd(string.format("wincmd %s", cmd))
        cur = vim.api.nvim_get_current_win()
        if cur == beg then break end
        vim.cmd("q")
      end
    end
    vim.keymap.set('n', string.format("Z<%s>", Dir), f)
    vim.keymap.set('n', string.format("Z<S-%s>", Dir), f)
  end
  vim.keymap.set('n', "ZA", "<CMD>qa!<CR>")
'';}
