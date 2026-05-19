{ pkgs, ... }: let
  nixd = (pkgs.flake-compat {src = pkgs.npinsed.nixd;})
  .defaultNix.packages.${pkgs.stdenv.system}.default;
in {
  programs.neovim = {
    extraLuaConfig = "vim.lsp.enable('nixd')\n";
    extraPackages=[nixd];
  };
}
