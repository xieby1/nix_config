{ pkgs, ... }:
let
  src = pkgs.applyPatches {
    name = "pi-apply-patch-slim";
    src = pkgs.npinsed.ai.pi.apply-patch;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq '
        .pi.extensions = ["./index.ts"]
        | del(.devDependencies, .peerDependencies, .scripts)
      ' package.json > package.json.tmp
      mv package.json.tmp package.json
      echo 'export { default } from "./src/index.ts";' > index.ts
      jq '
        .packages |= with_entries(select(.key == "" or .key == "node_modules/diff"))
        | .packages[""] |= del(.devDependencies, .peerDependencies)
      ' package-lock.json > package-lock.json.tmp
      mv package-lock.json.tmp package-lock.json
    '';
  };
in
{
  home.file.".pi/agent/extensions/pi-apply-patch".source =
    pkgs.buildNpmPackage {
      name = "pi-apply-patch";
      inherit src;
      npmDepsHash = "sha256-T5d7AQtItiIKt2vFhBZlmY65grjwU3bvp8v4rlecv0U=";
      dontNpmBuild = true;
    }
    + /lib/node_modules/pi-apply-patch;
}
