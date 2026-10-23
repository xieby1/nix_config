{ pkgs, ... }: let
  # Build from the pinned nixd source: nixpkgs 26.05 ships nixd 2.9.1, which
  # predates the `~/` tilde-path fix (nix-community/nixd#824, 2026-05-20) needed
  # by this repo's `~/.config/...` paths.
  # TODO: use `pkgs.nixd` once nixpkgs ships nixd >= 2.9.2 (`pkgs.pkgsu.nixd` is).
  nixd = (pkgs.flake-compat {src = pkgs.npinsed.nvim.nixd;})
  .defaultNix.packages.${pkgs.stdenv.system}.default;
in {
  programs.neovim = {
    initLua = "vim.lsp.enable('nixd')\n";
    extraPackages=[nixd];
  };
  cachix_packages = [nixd];
}
