{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./vim.nix
  ];

  home.packages = with pkgs; [
    # tools
    gitui
    unar
  ];

  # git
  programs.git = {
    enable = true;
    userEmail = "xieby1@outlook.com";
    userName = "xieby1";
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };

  # bash
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    view = "nvim -R";
  };
}
