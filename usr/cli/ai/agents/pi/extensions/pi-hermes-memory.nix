{ config, pkgs, lib, ... }: let
  # The node-gyp should be backed by the same version of nodejs as pi,
  # thus we use pkgspi.
  pkgspi = import (
    pkgs.flake-compat {src = pkgs.npinsed.ai.llm-agents;}
  ).outputs.inputs.nixpkgs {};
in {
  home.file.".pi/agent/extensions/pi-hermes-memory" = {
    source = pkgspi.buildNpmPackage {
      name = "pi-hermes-memory";
      src = pkgs.npinsed.ai.pi.pi-hermes-memory;
      npmDepsHash = "sha256-t5jQWrucm0Fm5V2PkC0btVWe7cwvrp1HuKqTwl38xA8=";
      dontNpmBuild = true;
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
