{ pkgs, ... }: let
  # TODO: use the nix from nixpkgs, maybe 26.05?
  #       The current tilde support is added in 2026.05.20
  nixd = (pkgs.flake-compat {src = pkgs.npinsed.nvim.nixd;})
  .defaultNix.packages.${pkgs.stdenv.system}.default;
in {
  programs.neovim = {
    extraLuaConfig = "vim.lsp.enable('nixd')\n";
    extraPackages=[nixd];
  };
  cachix_packages = [nixd];
}
