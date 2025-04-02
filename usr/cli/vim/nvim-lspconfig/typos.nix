{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      require'lspconfig'.typos_lsp.setup{}
    '';
    extraPackages = [
      pkgs.typos-lsp
    ];
  };
}
