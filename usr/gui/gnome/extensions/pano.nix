#MC # pano: Next-gen Clipboard Manager for Gnome Shell
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.pano
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "pano@elhan.io"
      ];
    };
    "org/gnome/shell/extensions/pano" = {
      play-audio-on-copy=false;
      send-notification-on-copy=false;
      paste-on-select=false;
    };
  };
}
