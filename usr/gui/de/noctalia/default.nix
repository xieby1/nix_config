{ config, ... }: {
  imports = [
    ./settings.nix
    ./pi-noctalia
    ./calendar-event-titles
  ];
  programs.noctalia = {
    enable = true;
  };
  cachix_packages = [ config.programs.noctalia.package ];
}
