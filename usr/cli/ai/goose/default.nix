{ pkgs, ... }: {
  home.packages = [
    # TODO: use latest nixpkgs and remove nixpkgs-goose-cli
    # https://github.com/NixOS/nixpkgs/issues/507256
    (import pkgs.npinsed.ai.nixpkgs-goose-cli {}).goose-cli
  ];
}
