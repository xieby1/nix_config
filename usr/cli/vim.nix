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
  # pluginWithConfigType is not displayed in `man home-configuration.nix`
  # see its avaiable config in `home-manager/modules/programs/neovim.nix`
  myTreesitters = {
    # TODO: declarative way to add nvim-treesitter's plugins
    # https://nixos.wiki/wiki/Tree_sitters
    # (
    #   nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars)
    # )
    plugin = pkgs.vimPlugins.nvim-treesitter;
    type = "lua";
    config = ''
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = {"c", "cpp", "python", "markdown"},
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = {
            "nix",
          },
        },
      }
    '';
  };
  my-nvim-config-local = {
    plugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
      name = "nvim-config-local";
      src = pkgs.fetchFromGitHub {
        owner = "klen";
        repo = "nvim-config-local";
        rev = "af59d6344e555917209f7304709bbff7cea9b5cc";
        sha256 = "1wg6g4rqpj12sjj0g1qxqgcpkzr7x82lk90lf6qczim97r3lj9hy";
      };
    };
    config = ''
      lua << EOF
      require('config-local').setup {
        lookup_parents = true,
        silent = true,
      }
      EOF
      augroup config-local
        autocmd BufEnter * nested lua require'config-local'.source()
      augroup END
    '';
  };
in

{
  # neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = builtins.readFile ./xvimrc;
    plugins = with pkgs.vimPlugins; [
      vim-gitgutter
      vim-smoothie
      vim-mark
      vim-ingo-library
      vim-fugitive
      git-messenger-vim
      DrawIt
      vim-nix
      vim-floaterm
      vim-markdown-toc
      vista-vim
      vim-commentary
      myTreesitters
      # python lsp support:
      #   coc related info:
      #     https://github.com/neoclide/coc.nvim/wiki/Language-servers#python
      #       https://github.com/fannheyward/coc-pyright
      #   nixos vim related info:
      #     https://nixos.wiki/wiki/Vim
      #       https://github.com/NixOS/nixpkgs/issues/98166#issuecomment-725319238
      coc-pyright
      vim-markdown # format table
      tabular
      vim-hexokinase
      vim-plugin-AnsiEsc
      my-nvim-config-local
      lightspeed-nvim
      # {
      #   plugin = indentLine;
      #   config = ''
      #     " prevent conceal vim-markdown ```
      #     "" https://github.com/Yggdroot/indentLine
      #     "" Disabling conceal for JSON and Markdown without disabling indentLine plugin
      #     let g:vim_json_conceal = 0
      #     let g:vim_markdown_conceal = 0
      #   '';
      # }
    ];
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      ccls
    ];

    # coc
    withNodeJs = true;
    coc.enable = true;
    # bug: neovim: rebuilding with coc support does not work when nodejs is in PATH
    # https://github.com/nix-community/home-manager/issues/2966
    # Solution:
    # https://github.com/sumnerevans/home-manager-config/commit/da138d4ff3d04cddb37b0ba23f61edfb5bf7b85e
    coc.package = pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "coc.nvim";
      version = "2022-05-21";
      src = pkgs.fetchFromGitHub {
        owner = "neoclide";
        repo = "coc.nvim";
        rev = "791c9f673b882768486450e73d8bda10e391401d";
        sha256 = "sha256-MobgwhFQ1Ld7pFknsurSFAsN5v+vGbEFojTAYD/kI9c=";
      };
      meta.homepage = "https://github.com/neoclide/coc.nvim/";
    };
    coc.settings = {
      "suggest.noselect" = true;
      "suggest.enablePreview" = true;
      "suggest.enablePreselect" = false;
      # language server config refers to:
      # https://github.com/neoclide/coc.nvim/wiki/Language-servers
      "languageserver" = {
        "ccls" = {
          "command" = "ccls";
          "filetypes" = ["c" "cc" "cpp" "c++" "objc" "objcpp"];
          "rootPatterns" = [".ccls" "compile_commands.json" ".git/" ".hg/"];
          "initializationOptions" = {
            "cache" = {
              "directory" = "/tmp/ccls";
            };
          };
        };
      };
    };
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
