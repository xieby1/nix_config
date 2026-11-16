{ ... }: {
  # Ctrl+Shift+V converts clipboard HTML only in filetype=markdown buffers.
  # Open a .md file or use :set filetype=markdown in an unnamed buffer; p/P is unchanged.
  programs.neovim.initLua = /*lua*/ ''
    local paste = vim.paste
    local chunks

    local function clipboard(mime)
      local result = vim.system({ "wl-paste", "-n", "-t", mime }, { text = true }):wait()
      return result.code == 0 and result.stdout or nil
    end

    local function markdown_paste(lines)
      if vim.bo.filetype ~= "markdown" or vim.fn.mode():sub(1, 1) == "c"
        or vim.fn.executable("wl-paste") == 0 or vim.fn.executable("pandoc") == 0 then
        return lines
      end
      if clipboard("text/plain") ~= table.concat(lines, "\n") then return lines end
      local html = clipboard("text/html")
      if not html or html == "" then return lines end
      local md = vim.system(
        { "pandoc", "-f", "html", "-t", "gfm", "--wrap=none" },
        { stdin = html, text = true }
      ):wait()
      if md.code ~= 0 or md.stdout == "" then return lines end
      return vim.split(md.stdout:gsub("\n$", ""), "\n", { plain = true })
    end

    vim.paste = function(lines, phase)
      if phase == -1 then return paste(markdown_paste(lines), phase) end
      if phase == 1 then
        chunks = vim.bo.filetype == "markdown"
          and vim.fn.mode():sub(1, 1) ~= "c" and {} or nil
      end
      if not chunks then return paste(lines, phase) end
      chunks[#chunks + 1] = table.concat(lines, "\n")
      if phase ~= 3 then return true end
      local complete = vim.split(table.concat(chunks), "\n", { plain = true })
      chunks = nil
      return paste(markdown_paste(complete), -1)
    end
  '';
}
