{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require'lspconfig'.lemminx.setup{
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }
    '';
    extraPackages = [
      pkgs.lemminx
    ];
  };
}
