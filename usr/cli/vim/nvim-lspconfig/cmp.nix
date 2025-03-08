{ ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
      local servers = {
        'ltex',
        'clangd',
        'nixd',
        'html',
        'pyright',
        'lua_ls',
      }
      for _, lsp in ipairs(servers) do
        require('lspconfig')[lsp].setup {
          -- on_attach = my_custom_on_attach,
          capabilities = capabilities,
        }
      end
    '';
  };
}
