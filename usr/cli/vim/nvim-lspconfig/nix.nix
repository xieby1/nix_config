#MC # lspconfig for nix
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("nixd")
    '';
    extraPackages = with pkgs; [
      nixd
    ];
  };
}
