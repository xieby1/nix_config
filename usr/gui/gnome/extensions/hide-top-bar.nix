#MC # hide-top-bar
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.hide-top-bar
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "hidetopbar@mathieu.bidon.ca"
      ];
    };
    "org/gnome/shell/extensions/hidetopbar" = {
      mouse-sensitive = true;
      enable-active-window=false;
      enable-intellihide=true;
      # enable shortcut <Super>+v show nofication list, <Super>+s show quick settings, and so on
      keep-round-corners=true;
      shortcut-delay = 0.0;
      shortcut-keybind = ["<Super>h"];
    };
  };
}
