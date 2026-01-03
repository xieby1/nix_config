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
      empty-workspace-left = ["<Alt><Control><Shift>Left"];
      empty-workspace-right = ["<Alt><Control><Shift>Right"];
      move-window-to-left-workspace = ["<Super><Control><Shift>Left"];
      move-window-to-right-workspace = ["<Super><Control><Shift>Right"];
      workspace-left = [""];
      workspace-right = [""];
    };
  };
}
