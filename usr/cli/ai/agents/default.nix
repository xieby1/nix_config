{ config, pkgs, ... }: {
  imports = [
    ./pi
    ./forge
    ./hermes
    ./goose
    ./zerostack
  ];
  home.packages = [
    # TODO: use latest nixpkgs and remove nixpkgs-for-copilot
    # copilot error: Invalid shell ID: 0. Please supply a valid shell ID to read output from.
    # https://github.com/NixOS/nixpkgs/pull/509133
    (import pkgs.npinsed.ai.nixpkgs-for-copilot {}).github-copilot-cli
  ];
  home.file.".agents/skills".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/agents/skills;
}
