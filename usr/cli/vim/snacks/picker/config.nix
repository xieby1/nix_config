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

        vim.keymap.set('n', '<space>c', function() Snacks.picker.command_history() end)
        vim.keymap.set('n', '<space>C', function() Snacks.picker.commands() end)

        vim.keymap.set('n', '<space>S', function() Snacks.picker.git_status() end)
        vim.keymap.set('n', '<space>p', function() Snacks.picker.pickers() end)

        -- By pi + gpt-5.5
        -- Fuzzy recursive file insertion via Snacks picker.
        -- Alternatives not chosen:
        -- - builtin <C-x><C-f>: only completes files in the current path level.
        -- - blink.cmp path source: also current-level path completion, not recursive fuzzy pick.
        -- - fzf-lua complete_path: works, but duplicates Snacks picker functionality.
        -- - plain Snacks put action: pastes a file but does not use/replace typed prefixes.
        local function insert_file_path(base_dir)
          -- Hide blink.cmp so its path menu does not overlap the Snacks picker.
          pcall(function() require("blink.cmp").hide() end)

          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_get_current_buf()
          local row, col = unpack(vim.api.nvim_win_get_cursor(win))
          local line = vim.api.nvim_get_current_line()

          -- Path-like token before the cursor, e.g. `./foo/ba`.
          local prefix = line:sub(1, col):match("[^%s'\"`{}%[%]()<>,;:]*$") or ""
          -- Directory part is preserved in inserted text; cwd resolves from the chosen base_dir.
          local dir_prefix = prefix:match("^(.*/)") or ""
          local is_absolute = dir_prefix:match("^[~/]") ~= nil
          local picker_cwd = dir_prefix ~= "" and (is_absolute and vim.fn.resolve(dir_prefix) or vim.fn.resolve(base_dir .. "/" .. dir_prefix)) or base_dir

          Snacks.picker.files({
            cwd = picker_cwd,
            confirm = function(picker, item)
              picker:close()
              if not item then
                return
              end

              -- Replace the typed prefix with the selected file path.
              local file = dir_prefix .. (item.file or item.text)
              if prefix ~= "" then
                vim.api.nvim_buf_set_text(buf, row - 1, col - #prefix, row - 1, col, {})
              end
              vim.api.nvim_win_set_cursor(win, { row, col - #prefix })
              vim.api.nvim_paste(file, true, -1)
              vim.schedule(function()
                vim.cmd.startinsert({ bang = true })
              end)
            end,
          })
        end

        vim.keymap.set("i", "<C-x><C-f>", function()
          insert_file_path(vim.fn.expand(("#%d:p:h"):format(vim.api.nvim_get_current_buf())))
        end, { desc = "Insert file path from buffer dir" })
        vim.keymap.set("i", "<C-x><C-w>", function()
          insert_file_path(vim.fn.getcwd())
        end, { desc = "Insert file path from cwd" })
      end
    '';
  };
}
