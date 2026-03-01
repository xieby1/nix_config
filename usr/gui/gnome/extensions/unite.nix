#MC # unite: unite style
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.unite
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [ "unite@hardpixel.eu" ];
    };
    "org/gnome/shell/extensions/unite" = {
      app-menu-ellipsize-mode="end";
      extend-left-box=false;
      greyscale-tray-icons=false;
      hide-app-menu-icon=false;
      hide-dropdown-arrows=true;
      hide-window-titlebars="always";
      notifications-position="center";
      reduce-panel-spacing=true;
      show-window-buttons="always";
      use-activities-text = false;
      window-buttons-placement="last";
      window-buttons-theme="materia";
      restrict-to-primary-screen=false;
    };
  };
}
