{ config, pkgs, lib, ... }: let
  # The node-gyp should be backed by the same version of nodejs as pi,
  # thus we use pkgspi.
  pkgspi = import (
    pkgs.flake-compat {src = pkgs.npinsed.ai.pi.llm-agents;}
  ).outputs.inputs.nixpkgs {};
in {
  home.file.".pi/agent/extensions/pi-hermes-memory" = {
    source = pkgspi.buildNpmPackage {
      name = "pi-hermes-memory";
      src = pkgs.npinsed.ai.pi.pi-hermes-memory;
      # npm lockfile v3 delegates to shrinkwrap → missing integrity; v2 fetcher handles this.
      npmDepsFetcherVersion = 2;
      npmDepsHash = "sha256-OeR+8j7Ayyx1jUSt6uBhQ7YsWGLR7POEnW+bLPu7UDQ=";
      patches = [ ./lock-integrity.patch ];
      dontNpmBuild = true;
      # Pi uses the first path segment of pi.extensions entry as the banner
      # display name. Upstream uses "./src/index.ts" which shows as "src".
      # Move the entrypoint to "./index.ts" so it falls back to package name.
      postInstall = ''
        cd $out/lib/node_modules/pi-hermes-memory
        sed -i 's|"./src/index.ts"|"./index.ts"|' package.json
        echo 'export { default } from "./src/index.ts";' > index.ts
      '';
      nativeBuildInputs = with pkgspi; [
        node-gyp
        python3
      ];
    } + /lib/node_modules/pi-hermes-memory;
  };
  home.file.".pi/agent/projects-memory".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/projects-memory;

  # pi-hermes-memory writes MEMORY.md/USER.md via temp-file + rename, which would
  # replace per-file symlinks. Symlink the whole writable directory instead.
  home.file.".pi/agent/pi-hermes-memory".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory;
  my.syncthing.Gist-stignore = lib.mkAfter [
    "/Data/pi/pi-hermes-memory/sessions.db"
    "/Data/pi/pi-hermes-memory/sessions.db-*"
  ];
}
