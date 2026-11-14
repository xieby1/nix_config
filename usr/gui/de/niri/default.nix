{ depkgs }: # local args
{ config, ... }: {
  imports = [
    ./config
    ./win_align.nix
    ./focus-shrink
  ];
  wayland.windowManager.niri.enable = true;
  cachix_packages = [ config.wayland.windowManager.niri.package ];
  services.gnome-keyring.enable = true;
}
