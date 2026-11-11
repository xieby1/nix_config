{ src }: # local-args
{ pkgs, lib, ... }:
let
  package = pkgs.buildNpmPackage {
    name = "pi-subagents";
    inherit src;
    npmDepsHash = "sha256-IwiXL+YzM0jSlOnq/tmlTV9nA6ydWDwoFg3kUFbeOhs=";
    dontNpmBuild = true;
    postPatch = ''
      ${lib.getExe pkgs.jq} 'del(.devDependencies, .peerDependencies, .peerDependenciesMeta, .scripts)' \
        package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in {
  yq-merge.".pi/agent/settings.json".expr.packages = [
    "${package}/lib/node_modules/pi-subagents"
  ];
}
