{ ... }: {
  programs.noctalia.settings = {
    plugins = {
      enabled = [
        "raycursive/niri-displays"
      ];
    };
  };
  xdg.desktopEntries.niri-displays = {
    name = "Noctalia Niri Displays";
    exec = "noctalia msg panel-toggle raycursive/niri-displays:panel";
    icon = "noctalia";
  };
}
