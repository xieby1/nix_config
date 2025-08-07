#MC # transparent-top-bar: able to adjust transparency
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.transparent-top-bar-adjustable-transparency
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "transparent-top-bar@ftpix.com"
      ];
    };
    "com/ftpix/transparentbar" = {
      dark-full-screen = false;
      transparency = 40;
    };
  };
}
