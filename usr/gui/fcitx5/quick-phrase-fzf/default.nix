{ pkgs, ... }: let
  class = "cn.xieby1.fcitx-quick-phrase-fzf";
  quick-phrase-fzf = import ./package.nix { inherit pkgs; };
in {
  xdg.desktopEntries.quick_phrase_fzf = {
    name = "Fcitx Quick Phrase FZF";
    genericName = "Fcitx quick phrase picker";
    exec = "ghostty --class=${class} -e ${quick-phrase-fzf}/bin/quick-phrase-fzf";
    icon = ./icon.svg;
    settings.StartupWMClass = class;
  };
}
