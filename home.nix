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
  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # gnome extensions
    gnome40Extensions."BingWallpaper@ineffable-gmail.com"
    gnome40Extensions."clipboard-indicator@tudmotu.com"
    gnomeExtensions.dash-to-dock
    gnome40Extensions."gTile@vibou"
    gnome40Extensions."hidetopbar@mathieu.bidon.ca"
    ## not work
    gnomeExtensions.no-title-bar
    gnomeExtensions.system-monitor
    gnomeExtensions.vertical-overview

    # tools
    gitui
    gnome.meld
    google-chrome

    # refer to https://nixos.wiki/wiki/Vim#Add_a_new_custom_plugin_to_the_users_packages
    # while I use VAM, so there are differences between above link and below
    (vim_configurable.customize {
      name = "vim"; # different to system-wide vim
      # noted: no quote in relative path, if so,
      # builtins.readFile "./vim/xvimrc" won't work
      vimrcConfig.customRC = builtins.readFile ./vim/xvimrc;
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

  programs.home-manager.enable = true;

  # gnome-terminal
  ## dconf dump /org/gnome/terminal/legacy/profiles:/
  programs.gnome-terminal.enable = true;
  programs.gnome-terminal.profile = {
    "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      visibleName = "xieby1";
      default = true;
      font = "Monospace 18";
      # Tango
      colors = {
        foregroundColor = "rgb(211,215,207)";
        backgroundColor = "rgb(46,52,54)";
        palette = [
          "rgb(465254)" "rgb(20400)" "rgb(781546)" "rgb(1961600)" "rgb(52101164)" "rgb(11780123)" "rgb(6152154)" "rgb(211215207)" "rgb(858783)" "rgb(2394141)" "rgb(13822652)" "rgb(25223379)" "rgb(114159207)" "rgb(173127168)" "rgb(52226226)" "rgb(238238236)"
        ];
      };
    };
  };

  # dconf
  dconf.settings = {
    "org/gnome/shell" = {
      ## enabled gnome extensions
      disable-user-extensions = false;
      enabled-extensions = [
        "BingWallpaper@ineffable-gmail.com"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "gTile@vibou"
        "hidetopbar@mathieu.bidon.ca"
        "Resource_Monitor@Ory0n"
        "system-monitor@paradoxxx.zero.gmail.com"
        "vertical-overview@RensAlthuis.github.com"
      ];

      ## dock icons
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "google-chrome.desktop"
        "org.gnome.Epiphany.desktop"
        #"firefox.desktop"
        ];
    };
    ## extensions settings
    "org/gnome/shell/extensions/system-monitor" = {
      compact-display=true;
      cpu-show-text=false;
      cpu-style="digit";
      icon-display=false;
      memory-show-text=false;
      memory-style="digit";
      net-show-text=false;
      net-style="digit";
      swap-display=false;
      swap-style="digit";
    };
    "org/gnome/shell/extensions/vertical-overview" = {
      override-dash=false;
    };
    "org/gnome/shell/extensions/gtile" = {
      animation=true;
      global-presets=true;
      grid-sizes="6x4,8x6";
      preset-resize-1=["<Super>bracketright"];
      preset-resize-2=["<Super>backslash"];
      preset-resize-3=["<Super>period"];
      preset-resize-4=["<Super>slash"];
      preset-resize-5=["<Super>apostrophe"];
      resize1="2x2 0:0 0:0";
      resize2="2x2 1:0 1:0";
      resize3="2x2 0:1 0:1";
      resize4="2x2 1:1 1:1";
      resize5="4x8 1:1 2:6";
      show-icon=false;
    };

    "org/gnome/desktop/session" = {
      idle-delay=lib.hm.gvariant.mkUint32 0; # never turn off screen
    };
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled=false;
      idle-dim=false;
      power-button-action="suspend";
      sleep-inactive-ac-timeout=3600;
      sleep-inactive-ac-type="nothing";
      sleep-inactive-battery-type="suspend";
    };
  };

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

  # vim
  ## home-manager:
  ## home-manager currently cannot manage customized vim plugin
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
  #
  #
  ## Directly use my github repo:
  ## ~/.vim is not a git repo, so experience is not good
  #
  ## ${home.homeDirectory} refer to `man home-configuration.nix`
  #home.file."${config.home.homeDirectory}/.vim".source =
  #  builtins.fetchGit {
  #    url = "git@github.com:xieby1/vimrc.git";
  #    ref = "master";
  #    submodules = true;
  #  };
}
