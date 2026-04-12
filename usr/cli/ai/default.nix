{ pkgs, ... }: {
  imports = [
    ./crush.nix
    ./pi
    ./llms
    ./forge.nix
  ];
  home.packages = [
    pkgs.pkgsu.github-copilot-cli
  ];
}
