{ pkgs, ... }:
let
  # No runtime deps: pi loads src/index.ts itself, so no npm build is needed.
  src = pkgs.npinsed.ai.pi.pi-tool-stats.outPath;
in {
  # But pi labels a directory extension by the folder holding its entry file, so
  # upstream's pi.extensions = ["./src/index.ts"] shows up as "src" in the
  # startup banner. Re-point the entry at a root shim to get "pi-tool-stats".
  home.file.".pi/agent/extensions/pi-tool-stats".source = pkgs.runCommand "pi-tool-stats" {
    nativeBuildInputs = [ pkgs.jq ];
  } ''
    cp -r ${src} $out
    chmod -R u+w $out
    jq '.pi.extensions = ["./index.ts"]' $out/package.json > $out/p.json
    mv $out/p.json $out/package.json
    echo 'export { default } from "./src/index.ts";' > $out/index.ts
  '';
}
