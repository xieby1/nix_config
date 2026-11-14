{ lib, ... }: let
  src = (import <npins> { input = ./sources.json; }).pi-noctalia;
in {
  home.file.".pi/agent/extensions/pi-noctalia".source = src + "/pi-extension";
  home.file.".local/share/noctalia/plugins/pi-noctalia".source = src + "/noctalia-plugin";
  programs.noctalia.settings = {
    bar.default = {
      start = lib.mkAfter [ "pi-noctalia" ];
    };
    plugins = {
      enabled = [ "local/pi-noctalia" ];
    };
    widget.pi-noctalia = {
      type = "local/pi-noctalia:widget";
      max_visible = 3;
    };
  };
}
