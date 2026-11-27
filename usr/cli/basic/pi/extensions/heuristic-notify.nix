{ src }: # local-args
{ ... }: {
  home.file.".pi/agent/extensions/pi-heuristic-notify.ts".source = src.outPath + "/src/index.ts";
}
