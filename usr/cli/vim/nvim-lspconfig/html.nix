#MC # lspconfig for html
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').html.setup{}
    '';
    extraPackages = with pkgs; [
      vscode-langservers-extracted # html
    ];
  };
}
