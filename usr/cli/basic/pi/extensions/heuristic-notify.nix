{ src }: # local-args
{ pkgs, ... }: {
  home.file.".pi/agent/extensions/pi-heuristic-notify.ts".source = src.outPath + "/src/index.ts";
}
