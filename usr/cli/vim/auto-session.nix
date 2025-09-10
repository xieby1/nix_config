#MC # auto sessions management
#MC
#MC auto-session vs persisted.nvim vs persistence-nvim
#MC
#MC * auto-session support multiple sessions per path (customized session name),
#MC   while other two not support
#MC * persisted-nvim support telescope, while persistence-nvim not
{ pkgs, ... }: { programs.neovim.plugins = [{
  # use latest auto-session for `custom_session_tag`
  plugin = pkgs.vimUtils.buildVimPlugin {
    name = "custom_session_tag";
    src = pkgs.fetchFromGitHub {
      owner = "rmagatti";
      repo = "auto-session";
      rev = "3b5d8947cf16ac582ef00443ede4cdd3dfa23af9";
      hash = "sha256-JOJNnz+1tzTJh5xTpkoTYPRAt4lR1HN7FP1fSXhzU2s=";
    };
    doCheck = false;
  };
  type = "lua";
  config = /*lua*/ ''
    require("auto-session").setup({
      -- auto_save will not update existing tag
      -- e.g.:
      -- * restore a session tag is (time1 win1┇win2)
      -- * ... some vim operations ...
      -- * when leave vim, there are only win1, the tag is expected to become (time2 win1)
      -- * However the tag is not updated, which is still (time1 win1┇win2)
      -- So I disable the original auto_save,
      -- and manually execute save when VimLeavePre,
      -- see VimLeavePre below.
      auto_save = false,
      auto_restore = false,
      args_allow_files_auto_save = true,
      -- auto purge session after 30 days
      purge_after_minutes = 60*24*30,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", { callback = function()
      local buffers = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name ~= "" then
          -- Extract just the filename from the full path
          local filename = vim.fn.fnamemodify(buf_name, ":~:.")
          table.insert(buffers, filename)
        end
      end

      local buffers_occurrences = {}
      for _, buf in ipairs(buffers) do
        if buffers_occurrences[buf] then
          buffers_occurrences[buf] = buffers_occurrences[buf] + 1
        else
          buffers_occurrences[buf] = 1
        end
      end

      local buffers_strs = {}
      for buf, occurrence in pairs(buffers_occurrences) do
        if occurrence == 1 then
          table.insert(buffers_strs, buf)
        else --[[occurrence > 1]]
          table.insert(buffers_strs, string.format("%s[%d]", buf, occurrence))
        end
      end

      table.sort(buffers_strs)

      require("auto-session").SaveSession(string.format("%s %s: %s",
        os.date("%d日"),
        vim.fn.fnamemodify(vim.fn.getcwd(), ":~"),
        table.concat(buffers_strs, ", ")
      ))
    end})
  '';
}];}
