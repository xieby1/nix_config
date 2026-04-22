#MC # hide-top-bar
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.hide-top-bar
    # https://extensions.gnome.org/extension/545/hide-top-bar/
    # > straydog77:
    # > If anyone is having issues with this extension behaving strangely like the top bar sometimes won't appear or appear briefly and disappear use the "disable-unredirect" extension in conjunction
    # > https://extensions.gnome.org/extension/8008/disable-unredirect/
    pkgs.gnomeExtensions.disable-unredirect
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "hidetopbar@mathieu.bidon.ca"
        "disable-unredirect@exeos"
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
