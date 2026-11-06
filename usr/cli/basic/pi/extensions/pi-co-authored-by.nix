{ pkgs, ... }: {
  home.file.".pi/agent/extensions/pi-co-authored-by".source =
    pkgs.npinsed.ai.pi.shelken-pi-extensions.outPath + "/extensions/pi-co-authored-by";
}
