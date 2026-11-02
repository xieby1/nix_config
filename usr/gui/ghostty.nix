{ lib, ... }: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-size = (import ~/Gist/Config/kitty-font-size.nix).${lib.trim (builtins.readFile /etc/hostname)} or 14;
      font-family = "DejaVuSansMono";
      keybind = [
        "ctrl+shift+,=move_tab:-1"
        "ctrl+shift+.=move_tab:1"
      ];
    };
  };
}
