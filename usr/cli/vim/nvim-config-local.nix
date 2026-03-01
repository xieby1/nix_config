#MC # nvim-config-local: secure load local vim config
{ pkgs, ... }:
let
  my-nvim-config-local = {
    plugin = pkgs.vimPlugins.nvim-config-local;
    type = "lua";
    config = ''
      require('config-local').setup {
        config_files = { ".nvim.lua", ".nvimrc", ".exrc", ".vimrc" },
        lookup_parents = true,
        silent = true,
      }
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-nvim-config-local
    ];
  };
}
