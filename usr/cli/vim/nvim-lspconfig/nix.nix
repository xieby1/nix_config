#MC # lspconfig for nix
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').nixd.setup{}
    '';
    extraPackages = with pkgs; [
      nixd
    ];
  };
}
