{ ... }: let
  src = (import <npins> { input = ./sources.json; }).pi-noctalia;
in {
  home.file.".pi/agent/extensions/pi-noctalia".source = src + "/pi-extension";
  home.file.".local/share/noctalia/plugins/pi-noctalia".source = src + "/noctalia-plugin";
}
