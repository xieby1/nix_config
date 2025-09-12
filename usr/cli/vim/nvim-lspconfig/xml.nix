{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("lemminx")
    '';
    extraPackages = [
      pkgs.lemminx
    ];
  };
}
