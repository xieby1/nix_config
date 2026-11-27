{ pkgs, config, ... }: {
  imports = [
    ./config
    ./win_align.nix
    ./focus-shrink
  ];
  wayland.windowManager.niri.enable = true;
  cachix_packages = [ config.wayland.windowManager.niri.package ];
  services.gnome-keyring.enable = true;

  home.packages = [
    pkgs.adwaita-icon-theme
    pkgs.papirus-icon-theme
  ];
  wayland.windowManager.niri.settings = {
    cursor = {
      xcursor-theme = "Adwaita";
      xcursor-size = 24;
    };
  };
}
