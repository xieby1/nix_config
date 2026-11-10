{ pkgs, ... }: {
  home.shell.enableNushellIntegration = true;
  programs.nushell = {
    enable = true;
    package = pkgs.pkgsu.nushell;
    extraConfig = ''
      $env.config.completions.case_sensitive = true
    '';
  };
}
