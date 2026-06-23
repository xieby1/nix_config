{ config, pkgs, ... }: let
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
  home.file.".pi/agent/pi-hermes-memory/MEMORY.md".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory/MEMORY.md;
  home.file.".pi/agent/pi-hermes-memory/USER.md".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory/USER.md;
  home.file.".pi/agent/pi-hermes-memory/skills".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory/skills;
}
