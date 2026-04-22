{ pkgs, ... }: {
  imports = [
    ./crush.nix
    ./pi
    ./llms
    ./forge.nix
    ./kimi.nix
  ];
  home.packages = [
    # copilot error: Invalid shell ID: 0. Please supply a valid shell ID to read output from.
    # https://github.com/NixOS/nixpkgs/pull/509133
    (import pkgs.npinsed.ai.nixpkgs-for-copilot {}).github-copilot-cli
  ];
}
