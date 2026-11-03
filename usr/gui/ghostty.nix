# Terminal Comparsion
# * gnome-terminal
#   * Pros
#   * Cons
#     * Wrong window size, when window is tiled (e.g. use gTile)
#     * Icon display incorrectly (e.g. Vim-vista)
#     * It's hard to hide top bar
# * alacritty
#   * Pros
#     * Esay configurable
#     * Icon display correctly (e.g. Vim-vista)
#     * input method fcitx works
#   * Cons
#     * Not native tab support
#       https://github.com/alacritty/alacritty/issues/3129
#       The developer(s?) with poor attitude
#       * Compromise: tabbed
#     * Alacritty is not work with espanso
#       https://github.com/federico-terzi/espanso/issues/787
#       https://github.com/federico-terzi/espanso/issues/1088
#       In espanso auto mode, alacritty definitely will be stucked.
#       In clipboard, alacritty may be stucked.
#     * emoji display poorly.
# * kitty
#   * Pros
#     * Esay configurable
#   * Cons
#     * do not support search
# * hyper
#   * Cons
#     * scroll speed is too fast!
{ config, lib, ... }: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Exposes --ghostty-fg and --ghostty-bg for the GTK tab CSS below.
      window-theme = "ghostty";
      font-size = (import ~/Gist/Config/terminal-font-size.nix).${lib.trim (builtins.readFile /etc/hostname)} or 14;
      font-family = config.fonts.fontconfig.defaultFonts.monospace;
      gtk-custom-css = "${builtins.toFile "ghostty.css" ''
        headerbar {
          min-height: 10px;
          padding: 0;
          margin: 0;
        }

        tabbar tabbox {
          min-height: 10px;
          padding: 0;
          margin: -4px 0;
        }

        tabbar tabbox tab {
          padding: 0;
          margin: 0;
        }

        tabbar tabbox tab:not(:selected) {
          color: var(--ghostty-fg);
          background-color: var(--ghostty-bg);
        }

        tabbar tabbox tab:selected {
          color: var(--ghostty-bg);
          background-color: var(--ghostty-fg);
        }
      ''}";
      keybind = [
        "ctrl+shift+,=move_tab:-1"
        "ctrl+shift+.=move_tab:1"
        "ctrl+shift+[=goto_split:previous"
        "ctrl+shift+]=goto_split:next"
      ];
    };
  };

  programs.neovim.initLua = /*lua*/''
    -- [Linux tmux: scrolling distance with the mouse wheel #8875](https://github.com/ghostty-org/ghostty/discussions/8875)
    vim.opt.mousescroll = "ver:1,hor:1"
  '';
}
