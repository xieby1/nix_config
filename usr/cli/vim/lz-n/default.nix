# # lz.n vs lazy.nvim:
# - lazy.nvim contains too many unnecessary features (unrelated to lazy)!
{ pkgs, lib, ... }: {
  programs.neovim.plugins = [
    pkgs.vimPlugins.lz-n
  ];

  imports = [./module];
  my.neovim.lz-n = [{
    plugin = pkgs.pkgsu.vimPlugins.copilot-lua;
    cmd = "Copilot";
    after = lib.generators.mkLuaInline ''function() require("copilot").setup() end'';
  }];
}
