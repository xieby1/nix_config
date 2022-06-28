{ config, pkgs, stdenv, lib, ... }:
{
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
  #     * Icon display incorrectly (e.g. Vim-vista)

  ################## Alacritty ##################
  home.packages = with pkgs; [
    tabbed
  ];

  programs.alacritty.enable = true;
  home.file.alacritty = {
    source = ./alacritty.yml;
    target = ".config/alacritty/alacritty.yml";
  };

  #################### Kitty ####################
  programs.kitty = {
    enable = true;
    environment = {
      "TERM" = "xterm";
    };
    font = {
      name = "";
      size = 16;
    };
    settings = {
      cursor_blink_interval = "0.8";
      # tab
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      active_tab_foreground   = "#d3d7cf";
      active_tab_background   = "#2e3436";
      inactive_tab_foreground = "#2e3436";
      inactive_tab_background = "#d3d7cf";
      # tango dark
      background              = "#2e3436";
      foreground              = "#d3d7cf";
      cursor                  = "#d3d7cf";
      color0                  = "#2e3436";
      color8                  = "#555753";
      color1                  = "#cc0000";
      color9                  = "#ef2929";
      color2                  = "#4e9a06";
      color10                 = "#8ae234";
      color3                  = "#c4a000";
      color11                 = "#fce94f";
      color4                  = "#3465a4";
      color12                 = "#729fcf";
      color5                  = "#75507b";
      color13                 = "#ad7fa8";
      color6                  = "#06989a";
      color14                 = "#34e2e2";
      color7                  = "#d3d7cf";
      color15                 = "#eeeeec";
      selection_foreground    = "#2e3436";
      selection_background    = "#d3d7cf";
    };
    extraConfig = ''
      map alt+1 goto_tab 1
      map alt+2 goto_tab 2
      map alt+3 goto_tab 3
      map alt+4 goto_tab 4
      map alt+5 goto_tab 5
      map alt+6 goto_tab 6
      map alt+7 goto_tab 7
      map alt+8 goto_tab 8
      map alt+9 goto_tab 9
      map alt+0 goto_tab 99
      map ctrl+shift+t new_tab_with_cwd
    '';
  };
}
