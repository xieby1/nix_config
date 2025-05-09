#MC # gtile: tiled windows manager
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.gtile
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "gTile@vibou"
      ];
    };
    "org/gnome/shell/extensions/gtile" = {
      animation=true;
      global-presets=true;
      grid-sizes="16x10";
      preset-resize-1=["<Super>bracketleft"];
      preset-resize-2=["<Super>bracketright"];
      preset-resize-3=["<Super>comma"];
      preset-resize-4=["<Super>period"];
      preset-resize-5=["<Super>semicolon"];
      preset-resize-6=["<Super>apostrophe"];
      preset-resize-7=["<Super>slash"];
      resize1="2x2 1:1 1:1";
      resize2="2x2 2:1 2:1";
      resize3="2x2 1:2 1:2";
      resize4="2x2 2:2 2:2";
      resize5="4x8 2:2 3:7";
      resize6="1x2 1:1 1:1";
      resize7="1x2 1:2 1:2";
      show-icon=false;
    };
  };
}

