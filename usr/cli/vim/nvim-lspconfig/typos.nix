{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("typos_lsp")
    '';
    extraPackages = [
      pkgs.typos-lsp
    ];
  };
}
