{ src }: # local-args
{ pkgs, lib, ai, ... }: {
  home.file.".pi/agent/extensions/pi-title".source = pkgs.buildNpmPackage {
    pname = "pi-title";
    version = "0.1.9";
    inherit src;
    postPatch = ''
      ${lib.getExe pkgs.jq} 'del(.peerDependencies, .devDependencies, .scripts)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
    npmDepsHash = "sha256-r4w9nnnKSZzYnvZ0mAiZt2XSx4uqFixiMJsJDGqhr7o=";
    dontNpmBuild = true;
  } + "/lib/node_modules/pi-title";

  yq-merge.".pi/agent/pi-title.jsonc" = {
    generator = builtins.toJSON;
    expr = {
      refreshTurns = 5;
      model = "${ai.default_small.provider}/${ai.default_small.model.id}:${lib.head ai.default_small.model.reasoning_levels}";
    };
  };
}
