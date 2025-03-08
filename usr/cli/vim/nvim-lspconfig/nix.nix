#MC # lspconfig for nix
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').nixd.setup{}
      require('lspconfig')['nixd'].setup {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }
    '';
    extraPackages = with pkgs; [
      nixd
    ];
  };
}
