/*lua*/''
  picker = {
    -- ui_select = true, TODO: after completely remove telescope, enable this.
    layout = {
      -- based on vertical layout
      layout = {
        backdrop = false,
        box = "vertical",
        border = true,
        title = "{title} {live} {flags}",
        title_pos = "center",
        { win = "preview", title = "{preview}", height = 0.6, border = "bottom" },
        -- statuscolumn: show ">" on cursor line as current-item indicator
        { win = "list", border = "none", wo = { statuscolumn = "%#SnacksPickerListCursorLine#%{v:relnum==0?\">\":\" \"}%*" } },
        { win = "input", height = 1, border = "top" },
      },
      reverse = true,
      fullscreen = true,
    },
  },
''
