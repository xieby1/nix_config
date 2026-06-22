{ pkgs, ... }: let
  buildNpmPackage = pkgs.buildNpmPackage.override {
    nodejs = pkgs.nodejs_24;
  };
in {
  home.file.".pi/agent/extensions/pi-hermes-memory" = {
    source = buildNpmPackage {
      name = "pi-hermes-memory";
      src = pkgs.npinsed.ai.pi.pi-hermes-memory;
      npmDepsHash = "sha256-t5jQWrucm0Fm5V2PkC0btVWe7cwvrp1HuKqTwl38xA8=";
      dontNpmBuild = true;
      nativeBuildInputs = with pkgs; [
        nodejs_24.pkgs.node-gyp
        python3
      ];
    } + /lib/node_modules/pi-hermes-memory;
  };
}
