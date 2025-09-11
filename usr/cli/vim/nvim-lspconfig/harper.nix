{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').harper_ls.setup {}
    '';
    extraPackages = [
      pkgs.harper
    ];
  };
}
