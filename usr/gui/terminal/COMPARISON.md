# Terminal Comparison

* gnome-terminal
  * Pros
  * Cons
    * Wrong window size, when window is tiled (e.g. use gTile)
    * Icon display incorrectly (e.g. Vim-vista)
    * It's hard to hide top bar
* alacritty
  * Pros
    * Esay configurable
    * Icon display correctly (e.g. Vim-vista)
    * input method fcitx works
  * Cons
    * Not native tab support
      https://github.com/alacritty/alacritty/issues/3129
      The developer(s?) with poor attitude
      * Compromise: tabbed
    * Alacritty is not work with espanso
      https://github.com/federico-terzi/espanso/issues/787
      https://github.com/federico-terzi/espanso/issues/1088
      In espanso auto mode, alacritty definitely will be stucked.
      In clipboard, alacritty may be stucked.
    * emoji display poorly.
* kitty
  * Pros
    * Esay configurable
  * Cons
    * do not support search
* hyper
  * Cons
    * scroll speed is too fast!
* ghostty
  * Cons
    * Tab title stays on Neovim's filename after exiting Neovim opened from LazyGit;
      Kitty restores LazyGit's title.
      Ghostty parses but does not implement title push/pop (CSI 22/23):
      [ghostty#2668](https://github.com/ghostty-org/ghostty/issues/2668) is still open;
      last updated 2024-11-16 (nearly two years ago as of 2026-11-04).
