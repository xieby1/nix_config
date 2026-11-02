{ pkgs, ... }: {
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    emoji = [
      "Noto Color Emoji"
      "Noto Emoji"
    ];
    # Kitty you `fc-match monospace` to search fallback fonts
    # More details see: https://github.com/kovidgoyal/kitty/discussions/4007
    monospace = [
      "DejaVu Sans Mono"
      "Noto Sans Mono CJK SC"
      "FiraCode Nerd Font Mono"
    ];
    sansSerif = [
      "DejaVu Sans"
      "Noto Sans CJK SC"
      "FiraCode Nerd Font"
    ];
    serif = [
      "DejaVu Serif"
      "Noto Serif CJK SC"
      "FiraCode Nerd Font"
    ];
  };

  home.packages = with pkgs; [
    # vim vista need nerd fonts
    # https://github.com/liuchengxu/vista.vim/issues/74
    # https://github.com/liuchengxu/space-vim/wiki/tips#programming-fonts
    # available nerd fonts: nixpkgs/pkgs/data/fonts/nerdfonts/shas.nix
    ## use non-variable noto font for feishu and other old electron apps
    ## for more details see: https://github.com/NixOS/nixpkgs/issues/171976
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    (noto-fonts.override { variants = [ "NotoSansSymbols2" ]; })
  ];
}
