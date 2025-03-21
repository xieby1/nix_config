#MC # lspconfig for python
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').pyright.setup{}
      require('lspconfig')['pyright'].setup {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }
    '';
    extraPackages = with pkgs; [
      pyright
    ];
  };
}
