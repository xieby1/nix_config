#MC # lspconfig for python
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').pyright.setup{}
    '';
    extraPackages = with pkgs; [
      pyright
    ];
  };
}
