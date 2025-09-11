{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require'lspconfig'.lemminx.setup{}
    '';
    extraPackages = [
      pkgs.lemminx
    ];
  };
}
