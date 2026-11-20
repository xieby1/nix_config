{ pkgs, lib, ... }:
let
  extension = import ./package.nix { inherit pkgs; };
  model = import ./model.nix { inherit pkgs; };
in lib.mkIf (builtins.elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) {
  home.file.".pi/agent/extensions/pi-read-aloud".source = extension + "/lib/node_modules/pi-read-aloud";
  home.file.".pi/models/tts/${model.modelId}".source = model;
  home.packages = [ pkgs.mpv-unwrapped ];
}
