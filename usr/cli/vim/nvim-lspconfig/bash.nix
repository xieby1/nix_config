#MC # bashls: bash language server
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').bashls.setup{}
    '';
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
    ];
  };
}
