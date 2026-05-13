{ pkgs, ... }: {
  imports = [
    ./pi
    ./llms
    ./forge
    ./picoclaw.nix
    ./mcp/vestige
  ];
  home.packages = [
    # TODO: use latest nixpkgs and remove nixpkgs-for-copilot and nixpkgs-goose-cli
    # copilot error: Invalid shell ID: 0. Please supply a valid shell ID to read output from.
    # https://github.com/NixOS/nixpkgs/pull/509133
    (import pkgs.npinsed.ai.nixpkgs-for-copilot {}).github-copilot-cli
    # https://github.com/NixOS/nixpkgs/issues/507256
    (import pkgs.npinsed.ai.nixpkgs-goose-cli {}).goose-cli
  ];
}
