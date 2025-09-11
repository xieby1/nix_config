{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("harper_ls")
    '';
    extraPackages = [
      pkgs.harper
    ];
  };
}
