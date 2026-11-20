{ ... }: {
  # Ctrl+Shift+V keeps plain-text paste, including text selected in a terminal.
  # :PasteMd explicitly converts clipboard HTML to Markdown.
  programs.neovim.initLua = /*lua*/ ''
    vim.api.nvim_create_user_command("PasteMd", function()
      local html = vim.system(
        { "wl-paste", "-n", "-t", "text/html" }, { text = true }
      ):wait()
      if html.code ~= 0 or html.stdout == "" then
        error("PasteMd: clipboard has no text/html", 0)
      end

      local md = vim.system(
        {
          "pandoc", "-f", "html-native_divs-native_spans",
          "-t", "gfm-raw_attribute-raw_html", "--wrap=none",
        },
        { stdin = html.stdout, text = true }
      ):wait()
      if md.code ~= 0 or md.stdout == "" then
        error("PasteMd: pandoc could not convert the clipboard HTML", 0)
      end

      -- Drop embedded toolbar icons; keep ordinary image URLs.
      local text = md.stdout:gsub("!%[([^%]]*)%]%(data:image/[^)]*%)", "")
      local lines = vim.split(text:gsub("\n$", ""), "\n", { plain = true })
      vim.api.nvim_put(lines, "c", true, true)
    end, { desc = "Paste clipboard HTML as Markdown" })
  '';
}
