{ pkgs, ... }: {
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    pkgs.pkgsu.pi-coding-agent
  ];
}
