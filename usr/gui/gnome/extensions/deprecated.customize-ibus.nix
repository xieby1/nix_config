#MC # customize-ibus: input method customization
{ pkgs, lib, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.customize-ibus
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "customize-ibus@hollowman.ml"
      ];
    };
    "org/gnome/desktop/input-sources" = {
      sources = with lib.hm.gvariant; mkArray
      "(${lib.concatStrings [type.string type.string]})" [
        (mkTuple ["xkb"  "us"])
        (mkTuple ["ibus" "rime"])
        (mkTuple ["ibus" "mozc-jp"])
        (mkTuple ["ibus" "hangul"])
      ];
    };
    "org/gnome/shell/extensions/customize-ibus" = {
      candidate-orientation = lib.hm.gvariant.mkUint32 1;
      custom-font="Iosevka Nerd Font 16";
      enable-orientation=true;
      input-indicator-only-on-toggle=false;
      input-indicator-only-use-ascii=false;
      use-custom-font=true;
      use-indicator-show-delay=true;
    };
  };
}
