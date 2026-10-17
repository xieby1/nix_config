# Comparisons:
# - neoscroll.nvim: only support few scroll motion, does not support gg, G, S-up, S-down,
#                   see: https://github.com/karb94/neoscroll.nvim/issues/23
/*lua*/ ''
  scroll = {
    enabled = true,
    filter = function(buf)
      -- default filter does not allow in terminal, remove this limit!
      -- return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
      return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false
    end,
  },
''
