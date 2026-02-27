{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.typst-preview-nvim;
      type = "lua";
      config = /*lua*/ ''
        require ('typst-preview').setup({
          open_cmd = "single-tab %s",
        })
      '';
    }];
    extraLuaConfig = /*lua*/ ''
      -- https://www.reddit.com/r/neovim/comments/1iiqwb1/treesitter_injection_and_priority_issues/
      -- The `@lsp.type.comment.typst` can be obtained by hovering on the text, then `:Inspect`
      -- TLDR: I want to use typst injections.scm,
      --       while treesitter default highlight priority is 100,
      --       typst lsp highlight priority is 125.
      -- My failed attempts:
      -- * (#set! priority ): it only works in highlights.scm, does not work in injections.scm
      --   * See: https://github.com/nvim-treesitter/nvim-treesitter/issues/3110
      -- * Turn of tinymist lsp highlight:
      --   * `semanticTokens = "disable"` does not turn off tinymist lsp syntax highlight.
      -- So current my approach is keeping tinymist lsp highlight,
      -- only clear @lsp.type.comment.typst group.
      vim.api.nvim_set_hl(0, "@lsp.type.comment.typst", {})
      vim.lsp.enable('tinymist')
      vim.api.nvim_create_user_command("TypstExportPdfOnSaveToggle", function(args)
        if vim.lsp.get_clients({name="tinymist"})[1].settings.exportPdf ~= "onSave" then
          -- more settings see https://github.com/Myriad-Dreamin/tinymist/editors/neovim/Configuration.md
          vim.lsp.config("tinymist", {settings = {exportPdf = "onSave"}})
          -- compile and open pdf in evince
          local file_typ = vim.fn.expand('%:p')
          local file_pdf = vim.fn.expand('%:p:r') .. '.pdf'
          vim.system({'bash', '-c',
            'typst compile ' .. file_typ .. ' ' .. file_pdf .. ';' ..
            'evince ' .. file_pdf
          }, { text = true }, function()end)
          print("exportPdf = onSave")
        else
          vim.lsp.config("tinymist", {settings = {exportPdf = "never"}})
          print("exportPdf = never")
        end
        -- restart tinymist lsp, see `:h vim.lsp.enable`
        vim.lsp.enable("tinymist", false)
        vim.lsp.enable("tinymist", true)
      end, {})
    '';
    extraPackages = [ pkgs.tinymist ];
  };
  home.packages = [
    pkgs.typst
  ];
}
