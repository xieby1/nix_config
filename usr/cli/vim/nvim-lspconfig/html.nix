#MC # lspconfig for html
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("html")
    '';
    extraPackages = with pkgs; [
      vscode-langservers-extracted # html
    ];
  };
}
