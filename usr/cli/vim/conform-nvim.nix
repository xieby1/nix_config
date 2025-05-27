#MC # conform-nvim: formatter
{ pkgs, ... }: {
  programs.neovim = {
   plugins = [{
    plugin = pkgs.vimPlugins.conform-nvim;
    type = "lua";
    config = ''
      require("conform").setup({
        formatters_by_ft = {
          nix = { "nixfmt" },
          c = { "clang_format" },
          cpp = { "clang_format" },
        },
      })

      -- refer to https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#format-command
      vim.api.nvim_create_user_command("TrimWhitespace", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ formatters = {"trim_whitespace"}, range = range })
      end, { range = true })
      vim.keymap.set({'n','v'}, '<leader>f', ':TrimWhitespace<CR>')

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })
      vim.keymap.set({'n','v'}, '<leader>F', ':Format<CR>')
    '';
   }];
    extraPackages = with pkgs; [
      nixfmt-rfc-style
      clang-tools
    ];
  };
}
