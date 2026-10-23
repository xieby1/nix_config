/*lua*/''
  picker = {
    ui_select = true,
    win = {
      list = {
        wo = {
          -- Global list window config: show ">" on cursor line as current-item indicator
          -- for all picker layouts, not only the custom my_vertical preset.
          statuscolumn = "%#SnacksPickerListCursorLine#%{v:relnum==0?\">\":\" \"}%*",
        },
      },
    },
    layouts = {
      -- custom presets
      my_vertical = {
        layout = {
          backdrop = false,
          box = "vertical",
          border = true,
          title = "{title} {live} {flags}",
          title_pos = "center",
          { win = "preview", title = "{preview}", height = 0.6, border = "bottom" },
          { win = "list", border = "none" },
          { win = "input", height = 1, border = "top" },
        },
        reverse = true,
        fullscreen = true,
      },
    },
    -- Global Config
    -- Keep the global layout behind a named preset instead of defining the
    -- full layout table here. Per-source layouts (e.g. ui.select below) are
    -- deep-merged with the global layout; if the global value contains layout
    -- children directly, source presets inherit those children and may not
    -- resolve cleanly. A preset reference lets sources override with their own
    -- preset, such as the built-in "select" layout.
    layout = { preset = "my_vertical" },
    -- Per-source Config
    sources = {
      -- Config of ui.select
      select = {
        layout = { preset = "select" },
      },
      -- Snacks' LSP sources opt in to jump.reuse_win = true, which moves focus to
      -- a window that already shows the target file instead of replacing the
      -- current buffer. Keep jumps in the current window.
      lsp_definitions = { jump = { reuse_win = false } },
      lsp_declarations = { jump = { reuse_win = false } },
      lsp_type_definitions = { jump = { reuse_win = false } },
      lsp_implementations = { jump = { reuse_win = false } },
      lsp_references = { jump = { reuse_win = false } },
    },
  },
''
