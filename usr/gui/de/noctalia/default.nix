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
  xdg.desktopEntries.noctalia-settings = {
    name = "Noctalia Settings";
    exec = "noctalia msg settings-open";
    icon = "noctalia";
  };
}
