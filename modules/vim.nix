{ config, pkgs, stdenv, lib, ... }:

let
  vim-ingo-library = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ingo-library";
    src = builtins.fetchGit {
      url = "https://github.com/inkarkat/vim-ingo-library";
      ref = "master";
    };
  };
  vim-mark = pkgs.vimUtils.buildVimPlugin {
    name = "vim-mark";
    src = builtins.fetchGit {
      url = "https://github.com/inkarkat/vim-mark";
      ref = "master";
    };
  };
  DrawIt = pkgs.vimUtils.buildVimPlugin {
    name = "DrawIt";
    src = builtins.fetchGit {
      url = "https://github.com/vim-scripts/DrawIt";
      ref = "master";
    };
  };
in

{
  home.packages = with pkgs; [
    # refer to https://nixos.wiki/wiki/Vim#Add_a_new_custom_plugin_to_the_users_packages
    # while I use VAM, so there are differences between above link and below
    (vim_configurable.customize {
      name = "vim"; # different to system-wide vim
      # noted: no quote in relative path, if so,
      # builtins.readFile "./vim/xvimrc" won't work
      vimrcConfig.customRC = builtins.readFile ./../vim/xvimrc;
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins // {
        # add my cutomized vim plugins
        inherit vim-mark vim-ingo-library DrawIt;
      };
      vimrcConfig.vam.pluginDictionaries = [
        "vim-gitgutter"
        "vim-smoothie"
        "vim-mark"
        "vim-ingo-library"
        "ale"
        "YouCompleteMe"
        "vim-fugitive"
        "git-messenger-vim"
        "DrawIt"
        "vim-nix"
      ];
    })
  ];

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

  # Directly use my github repo:
  # ~/.vim is not a git repo, so experience is not good
  #
  ## ${home.homeDirectory} refer to `man home-configuration.nix`
  #home.file."${config.home.homeDirectory}/.vim".source =
  #  builtins.fetchGit {
  #    url = "git@github.com:xieby1/vimrc.git";
  #    ref = "master";
  #    submodules = true;
  #  };
}
