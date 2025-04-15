#MC # bashls: bash language server
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').bashls.setup{}
      require('lspconfig')['bashls'].setup {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }
    '';
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
    ];
  };
}
