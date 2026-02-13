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
