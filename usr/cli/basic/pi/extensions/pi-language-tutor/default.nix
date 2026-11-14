{ src }: # local-args
{ config, pkgs, lib, ... }:
let
  slimSrc = pkgs.applyPatches {
    name = "pi-language-tutor-slim";
    inherit src;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      substituteInPlace src/config.ts src/flashcards.ts src/flashcard-settings.ts \
        --replace-fail "'.pi', 'agent'," "'.pi', 'agent', 'pi-language-tutor',"
      substituteInPlace src/config.ts README.md README.zh-CN.md \
        --replace-fail '~/.pi/agent/language-learn.json' '~/.pi/agent/pi-language-tutor/language-learn.json'
      substituteInPlace README.md README.zh-CN.md \
        --replace-fail '~/.pi/agent/flashcards.json' '~/.pi/agent/pi-language-tutor/flashcards.json' \
        --replace-fail '~/.pi/agent/flashcards-settings.json' '~/.pi/agent/pi-language-tutor/flashcards-settings.json'
      jq 'del(.peerDependencies, .devDependencies, .scripts)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
      substituteInPlace src/learn.ts \
        --replace-fail "window.on('message', handleMessage)" \
        "window.on('message', handleMessage)
          window.on('error', (error: Error) => ctx.ui.notify(error.message, 'error'))"
    '';
  };
in {
  home.file.".pi/agent/extensions/pi-language-tutor".source = pkgs.buildNpmPackage {
    name = "pi-language-tutor";
    src = slimSrc;
    npmDepsHash = "sha256-B/zm5R+69hvwMYLkfUGMn0oVcXkO7lVKW/wAA+YZEdQ=";
    dontNpmBuild = true;
    npmRebuildFlags = [ "--ignore-scripts" ];
    postInstall = ''
      patch -p1 -d "$out/lib/node_modules/pi-language-tutor/node_modules/glimpseui" < ${./glimpse-stderr.patch}
    '';
  } + /lib/node_modules/pi-language-tutor;

  # Atomic writes replace file symlinks; link the writable directory instead.
  home.file.".pi/agent/pi-language-tutor".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-language-tutor;
  my.syncthing.Gist-stignore = lib.mkAfter [
    "/Data/pi/pi-language-tutor/*.tmp"
  ];
}
