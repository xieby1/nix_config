#MC # lspconfig for plain text
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').lua_ls.setup{}
      require('lspconfig')['lua_ls'].setup {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }
    '';
    extraPackages = with pkgs; [
      lua-language-server
    ];
  };
}
