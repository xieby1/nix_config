{ pkgs, ... }: {
  home.file.".pi/agent/extensions/pi-heuristic-notify.ts".source = pkgs.npinsed.ai.pi.pi-heuristic-notify.outPath + "/src/index.ts";
}
