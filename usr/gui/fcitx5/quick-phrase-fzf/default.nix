{ pkgs, ... }: let
  app-id = "fcitx-quick-phrase-fzf";
  quick-phrase-fzf = import ./package.nix { inherit pkgs; };
in {
  xdg.desktopEntries.quick_phrase_fzf = {
    name = "Fcitx Quick Phrase FZF";
    genericName = "Fcitx quick phrase picker";
    exec = "kitty --app-id ${app-id} ${quick-phrase-fzf}/bin/quick-phrase-fzf";
    icon = ./icon.svg;
    settings.StartupWMClass = app-id;
  };
}
