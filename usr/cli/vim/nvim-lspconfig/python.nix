#MC # lspconfig for python
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("pyright")
    '';
    extraPackages = with pkgs; [
      pyright
    ];
  };
}
