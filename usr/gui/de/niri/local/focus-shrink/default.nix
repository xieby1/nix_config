{ ... }: {
  patches = [
    # https://github.com/niri-wm/niri/discussions/1380
    ./main.patch
  ];
  configKdl = {
    animations.window-focus = {
      on-focus = {};
      scale = 0.9;
      duration-ms = 300;
      curve = "ease-out-cubic";
    };
    binds = {
      "Mod+Z".animate-window = {};
    };
  };
}
