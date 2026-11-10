{ pkgs, ... }: {
  home.shell.enableNushellIntegration = true;
  programs.nushell = {
    enable = true;
    package = pkgs.pkgsu.nushell;
  };
}
