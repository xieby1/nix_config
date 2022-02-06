{ config, pkgs, stdenv, lib, ... }:

let
  vim-ingo-library = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ingo-library";
    src = pkgs.fetchFromGitHub {
      owner = "inkarkat";
      repo = "vim-ingo-library";
      rev = "8ea0e934d725a0339f16375f248fbf1235ced5f6";
      sha256 = "1rabyhayxswwh85lp4rzi2w1x1zbp5j0v025vsknzbqi0lqy32nk";
    };
  };
  vim-mark = pkgs.vimUtils.buildVimPlugin {
    name = "vim-mark";
    src = pkgs.fetchFromGitHub {
      owner = "inkarkat";
      repo = "vim-mark";
      rev = "7f90d80d0d7a0b3696f4dfa0f8639bba4906d037";
      sha256 = "0n8r0ks58ixqv7y1afliabiqwi55nxsslwls7hni4583w1v1bbly";
    };
  };
  DrawIt = pkgs.vimUtils.buildVimPlugin {
    name = "DrawIt";
    src = pkgs.fetchFromGitHub {
      owner = "vim-scripts";
      repo = "DrawIt";
      rev = "master"; # I believe it wont update ^_*, so its safe
      sha256 = "0yn985pj8dn0bzalwfc8ssx62m01307ic1ypymil311m4gzlfy60";
    };
  };
in

{
  # neovim
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.coc.enable = true;
  programs.neovim.extraConfig =
    if builtins.pathExists ~/Codes/MyRepos/vimrc/xvimrc
    then
      builtins.readFile ~/Codes/MyRepos/vimrc/xvimrc
    else
      "";
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-gitgutter
    vim-smoothie
    vim-mark
    vim-ingo-library
    ale
    vim-fugitive
    git-messenger-vim
    DrawIt
    vim-nix
    coc-nvim
    vim-floaterm
    vim-markdown-toc
  ];
  programs.neovim.vimdiffAlias = true;

  # coc
  programs.neovim.withNodeJs = true;
  programs.neovim.coc.settings = {
    "suggest.noselect" = true;
    "suggest.enablePreview" = true;
    "suggest.enablePreselect" = false;
  };

  # 1.
  #home.packages = with pkgs; [
  #  # refer to https://nixos.wiki/wiki/Vim#Add_a_new_custom_plugin_to_the_users_packages
  #  # while I use VAM, so there are differences between above link and below
  #  (vim_configurable.customize {
  #    name = "vim"; # different to system-wide vim
  #    # noted: no quote in relative path, if so,
  #    # builtins.readFile "./vim/xvimrc" won't work
  #    vimrcConfig.customRC = builtins.readFile ./../vim/xvimrc;
  #    vimrcConfig.vam.knownPlugins = pkgs.vimPlugins // {
  #      # add my cutomized vim plugins
  #      inherit vim-mark vim-ingo-library DrawIt;
  #    };
  #    vimrcConfig.vam.pluginDictionaries = [
  #      "vim-gitgutter"
  #      "vim-smoothie"
  #      "vim-mark"
  #      "vim-ingo-library"
  #      "ale"
  #      "YouCompleteMe"
  #      "vim-fugitive"
  #      "git-messenger-vim"
  #      "DrawIt"
  #      "vim-nix"
  #    ];
  #  })
  #];

  # 2.
  # home-manager:
  # home-manager currently cannot manage customized vim plugin
  #
  #programs.vim = {
  #  enable = true;
  #  #plugins = with pkgs.vimPlugins; [
  #  #  vim-gitgutter
  #  #  vim-smoothie
  #  #];
  #programs.vim.packageConfigurable =
  #  pkgs.vim_configurable.customize {
  #  };
  #};

  # 3.
  # Directly use my github repo:
  # ~/.vim is not a git repo, so experience is not good
  #
  # ${home.homeDirectory} refer to `man home-configuration.nix`
  #home.file."${config.home.homeDirectory}/.vim" = {
  #  #recursive = true;
  #  # 3.3
  #  # fetchgit reserve .git, but belongs to root, cannot modify by user
  #  source = pkgs.fetchgit {
  #    url = "https://github.com/xieby1/vimrc";
  #    sha256 = "0h7mkhc0mqv2a1syffv0mb4dblgbgv72rlvs4ldxi03wm227h8r6";
  #    # ssh not work? may be executed by root?
  #    #url = "git@github.com:xieby1/vimrc.git";
  #    leaveDotGit = true;
  #  };
  #  # 3.2
  #  #source = /home/xieby1/vimrc;
  #  # 3.1
  #  #source = builtins.fetchGit {
  #  #  url = "git@github.com:xieby1/vimrc.git";
  #  #  ref = "master";
  #  #  submodules = true;
  #  #};
  #};
}
