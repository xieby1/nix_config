# # lz.n vs lazy.nvim:
# - lazy.nvim contains too many unnecessary features (unrelated to lazy)!
{ pkgs, ... }: {
  programs.neovim.plugins = [
    pkgs.vimPlugins.lz-n
  ];
}
