#MC # lspconfig for html
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').html.setup{}
      require('lspconfig')['html'].setup {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }
    '';
    extraPackages = with pkgs; [
      vscode-langservers-extracted # html
    ];
  };
}
