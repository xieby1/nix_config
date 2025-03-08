#MC # lspconfig for plain text
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').lua_ls.setup{}
    '';
    extraPackages = with pkgs; [
      lua-language-server
    ];
  };
}
