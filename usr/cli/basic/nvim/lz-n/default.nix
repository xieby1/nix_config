# # lz.n vs lazy.nvim:
# - lazy.nvim contains too many unnecessary features (unrelated to lazy)!
{ pkgs, lib, ... }: {
  programs.neovim.plugins = [
    pkgs.vimPlugins.lz-n
  ];

  imports = [
    ./module
    ./trim.nix
  ];
  my.neovim.lz-n = [];
}
