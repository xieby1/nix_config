{ config, pkgs, ... }: {
  home.file.niri_config = {
    text = config.lib.generators.toKDL {} {
      # TODO: support multiple same name attr, e.g. include
      include = "./dms/outputs.kdl";
      output = {
        _args = ["eDP-1"];
        scale = 2.0;
      };
      input = {
        touchpad = {
          tap = {};
        };
      };
      layout = {
        gaps = 0;
        focus-ring.off = {};
        shadow = {
          on = {};
          spread = 2;
          offset._props = {x=2; y=2;};
        };
        empty-workspace-above-first = {};
      };
      spawn-at-startup = ["dms" "run"];
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      binds = import ./binds.nix {inherit pkgs;};
      gestures.hot-corners.off = {};
      overview.zoom = 0.4;
      switch-events = {
        lid-close.spawn = ["dms" "ipc" "lock" "lock"];
      };
    };
    target = ".config/niri/config.kdl";
  };
}
