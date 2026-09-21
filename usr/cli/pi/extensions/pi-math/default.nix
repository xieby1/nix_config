{ pkgs, ... }:
let
  slimSrc = pkgs.applyPatches {
    name = "pi-math-slim";
    src = pkgs.npinsed.ai.pi.pi-math;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq 'del(.peerDependencies, .devDependencies, .scripts)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in {
  home.file.".pi/agent/extensions/pi-math".source = pkgs.buildNpmPackage {
    name = "pi-math";
    src = slimSrc;
    npmDepsHash = "sha256-gC8Y468G8f3AOVnggrWQYm3uO1IgVujviPJzfSjX/iE=";
    dontNpmBuild = true;
    postInstall = ''
      cd "$out/lib/node_modules/@monotykamary/pi-math"
      sed -i 's|"./src/index.ts"|"./index.ts"|' package.json
      echo 'export { default } from "./src/index.ts";' > index.ts
    '';
  } + "/lib/node_modules/@monotykamary/pi-math";
}
