{ ... }: {
  nixpkgs.overlays = [
    (self: super: {
      niri = super.niri.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          # https://github.com/niri-wm/niri/discussions/1380
          ./main.patch
        ];
      });
    })
  ];
  wayland.windowManager.niri.settings = {
    animations.window-focus = {
      on-keyboard = {};
      on-mouse = false;
      window-switch-only = {};
      scale = 0.9;
      duration-ms = 300;
      curve = "ease-out-cubic";
    };
    binds = {
      "Mod+Z".animate-window = {};
    };
  };
}
