#MC # kitty
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
  #     * Icon display incorrectly (e.g. Vim-vista)
  #     * input method support solved by fcitx5
  # * hyper
  #   * Cons
  #     * scroll speed is too fast!

  imports = [
    ./timer.nix
    ./search.nix
  ];

  # shortcuts
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kitty/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/fzf-doc/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/fzf-doc-background/"
  ];
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kitty" = {
    binding="<Primary><Alt>t";
    command = "kitty";
    name="terminal";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/fzf-doc" = {
    binding="<Super>f";
    # bash alias needs interative bash (-i)
    # https://askubuntu.com/questions/1109564/alias-not-working-inside-bash-shell-script
    command="kitty bash -i fzf-doc";
    name="fzf-doc";
  };

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
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";

      hide_window_decorations = "yes";
      cursor_blink_interval = "0.8";
      remember_window_size = "no";
      initial_window_width = "80c";
      initial_window_height = "20c";

      # tab
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      # tab_separator = " ┇"; This is default, a space before the vertical line
      active_tab_foreground   = "#e2e2e3";
      active_tab_background   = "#2c2e34";
      active_tab_title_template = "🐱{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}";
      inactive_tab_foreground = "#2c2e34";
      inactive_tab_background = "#e2e2e3";

      # tango dark
      background              = "#2c2e34";
      foreground              = "#e2e2e3";
      cursor                  = "#e2e2e3";
      color0                  = "#2c2e34";
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
      color7                  = "#e2e2e3";
      color15                 = "#eeeeec";
      # selection_foreground    = "#2c2e34";
      # selection_background    = "#e2e2e3";
    };
    extraConfig = ''
      map ctrl+equal change_font_size all +2.0
      map ctrl+plus change_font_size all +2.0
      map ctrl+kp_add change_font_size all +2.0
      map ctrl+minus change_font_size all -2.0
      map ctrl+kp_subtract change_font_size all -2.0
      map ctrl+0 change_font_size all 0

      map ctrl+shift+t new_tab_with_cwd
      map ctrl+shift+n new_os_window_with_cwd

      # disable opening of URLs with a plain click
      mouse_map left click ungrabbed no_op

      #: asks which tab to move the window into
      map f2 detach_window ask


      action_alias launch_window launch --cwd=current
      # Window layout
      enabled_layouts splits

      # Split and Create a new window
      map f5 launch_window --location=hsplit
      map f6 launch_window --location=vsplit

      # Goto window
      map alt+left neighboring_window left
      map alt+right neighboring_window right
      map alt+up neighboring_window up
      map alt+down neighboring_window down
    '';
  };
}
