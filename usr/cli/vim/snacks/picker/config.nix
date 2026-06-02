{ ... }: {
  programs.neovim = {
    extraLuaConfig = /*lua*/ ''
      do
        function get_buffer_dir()
          local file = vim.api.nvim_buf_get_name(0)
          return file ~= "" and vim.fs.dirname(file) or nil
        end

        -- f
        vim.keymap.set('n', "<space>f", function() Snacks.picker.files({ cwd = get_buffer_dir() }) end)
        vim.keymap.set('n', "<space>F", function() Snacks.picker.files() end)
        vim.keymap.set('n', "<space>b", function() Snacks.picker.buffers() end)
        -- s
        vim.keymap.set('n', "<space>g", function() Snacks.picker.grep({ cwd = get_buffer_dir() }) end)
        vim.keymap.set('n', "<space>G", function() Snacks.picker.grep() end)
        vim.keymap.set('n', "<space>h", function() Snacks.picker.help() end)

        vim.keymap.set('n', '<space>t', function() Snacks.picker.treesitter() end)
        vim.keymap.set('n', '<space>c', function() Snacks.picker.command_history() end)
        vim.keymap.set('n', '<space>C', function() Snacks.picker.commands() end)
      end
    '';
  };
}
