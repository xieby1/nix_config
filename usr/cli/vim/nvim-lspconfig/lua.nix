#MC # lspconfig for plain text
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("lua_ls")
    '';
    extraPackages = with pkgs; [
      lua-language-server
    ];
  };
}
