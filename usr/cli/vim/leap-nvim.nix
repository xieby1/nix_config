{ config, pkgs, stdenv, lib, ... }:
let
  my-leap-nvim = {
    plugin = pkgs.nur.repos.m15a.vimExtraPlugins.leap-nvim;
    type = "lua";
    config = ''
      require('leap').add_default_mappings()
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-leap-nvim
    ];
  };
}
