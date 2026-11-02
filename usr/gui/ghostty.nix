{ lib, ... }: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-size = (import ~/Gist/Config/kitty-font-size.nix).${lib.trim (builtins.readFile /etc/hostname)} or 14;
      font-family = "DejaVuSansMono";
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
      ''}";
      keybind = [
        "ctrl+shift+,=move_tab:-1"
        "ctrl+shift+.=move_tab:1"
      ];
    };
  };
}
