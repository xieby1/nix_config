{ config, lib, pkgs, ... }:
let
  ghostty = pkgs.pkgsu.ghostty.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./title-stack.patch
      ./scroll-mouse-report.patch
    ];
  });
in {
  cachix_packages = [ ghostty ];

  programs.ghostty = {
    enable = true;
    package = ghostty;
    enableZshIntegration = true;
    settings = {
      # Exposes --ghostty-fg and --ghostty-bg for the GTK tab CSS below.
      window-theme = "ghostty";
      gtk-wide-tabs = false;
      gtk-single-instance = false;
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
}
