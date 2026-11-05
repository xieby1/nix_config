{ pkgs, ... }:
let
  slimSrc = pkgs.applyPatches {
    name = "pi-language-tutor-slim";
    src = pkgs.npinsed.ai.pi.pi-language-tutor;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq 'del(.peerDependencies, .devDependencies, .scripts)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in {
  home.file.".pi/agent/extensions/pi-language-tutor".source = pkgs.buildNpmPackage {
    name = "pi-language-tutor";
    src = slimSrc;
    npmDepsHash = "sha256-B/zm5R+69hvwMYLkfUGMn0oVcXkO7lVKW/wAA+YZEdQ=";
    dontNpmBuild = true;
    npmRebuildFlags = [ "--ignore-scripts" ];
  } + /lib/node_modules/pi-language-tutor;

  yq-merge.".pi/agent/language-learn.json" = {
    generator = builtins.toJSON;
    expr = {
      learning = "en";
      native = "en";
      model = "jw2-deepseek/deepseek-flash";
    };
  };
}
