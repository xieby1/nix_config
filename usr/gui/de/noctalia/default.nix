{ config, ... }: {
  imports = [
    ./settings.nix
    ./plugins
    ./calendar-event-titles
  ];
  programs.noctalia = {
    enable = true;
  };
  cachix_packages = [ config.programs.noctalia.package ];
}
