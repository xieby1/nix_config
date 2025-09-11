#MC # bashls: bash language server
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      vim.lsp.enable("bashls")
    '';
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
    ];
  };
}
