{ pkgs, ... }:
let
  # No runtime deps and pi loads extensions/skills.ts itself, so no npm build.
  src = pkgs.npinsed.ai.pi.pify-skills.outPath;
in {
  # But pi labels a directory extension by the folder holding its entry file, so
  # upstream's pi.extensions = ["./extensions/skills.ts"] shows up as
  # "extensions" in the startup banner. Re-point the entry at a root shim to get
  # "pify-skills". /skills unused | cost | check.
  home.file.".pi/agent/extensions/pify-skills".source = pkgs.runCommand "pify-skills" {
    nativeBuildInputs = [ pkgs.jq ];
  } ''
    cp -r ${src} $out
    chmod -R u+w $out
    jq '.pi.extensions = ["./index.ts"]' $out/package.json > $out/p.json
    mv $out/p.json $out/package.json
    echo 'export { default } from "./extensions/skills.ts";' > $out/index.ts
  '';
}
