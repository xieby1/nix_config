#MC # pano: Next-gen Clipboard Manager for Gnome Shell
{ pkgs, ... }: {
  home.packages = [
    (pkgs.gnomeExtensions.pano.overrideAttrs (old: {
      # Referring to https://github.com/NixOS/nixpkgs/pull/461745/files
      # prepend_search_path => dup_default().prepend_search_path
      preInstall = builtins.replaceStrings
        ["prepend_search_path"]
        ["dup_default().prepend_search_path"]
        old.preInstall;
    }))
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
