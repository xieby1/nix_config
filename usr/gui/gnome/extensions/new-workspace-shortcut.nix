{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.new-workspace-shortcut
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "newworkspaceshortcut@barnix.io"
      ];
    };
    "org/gnome/shell/extensions/newworkspaceshortcut" = {
      empty-workspace-left = [""];
      empty-workspace-right = [""];
      workspace-left = [""];
      workspace-right = [""];
    };
  };
}
