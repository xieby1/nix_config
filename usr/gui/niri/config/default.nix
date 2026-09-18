{ config, pkgs, ... }: {
  home.file.niri_config = {
    text = /*kdl*/ ''
      include "./dms/colors.kdl"
      include "./dms/cursor.kdl"
      include "./dms/alttab.kdl"
      include "./dms/wpblur.kdl"
      // include "./dms/layout.kdl"
      include "./dms/outputs.kdl"
      include "./dms/binds.kdl"
      // TODO: move to evolution
      window-rule {
        match app-id="evolution-alarm-notify"
        open-floating true
        default-window-height { proportion 0.3; }
        default-column-width { proportion 0.3; }
      }
    '' + config.lib.generators.toKDL {} {
      prefer-no-csd = {};
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
      window-rule = {
        match._props.is-focused = false;
        clip-to-geometry = true ;
        # geometry-corner-radius._args= [12 36 36 12];
        geometry-corner-radius = 64;
      };
      spawn-at-startup = ["dms" "run"];
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      binds = import ./binds.nix {inherit pkgs;};
      gestures.hot-corners.off = {};
      overview.zoom = 0.4;
      switch-events = {
        lid-close.spawn = ["dms" "ipc" "lock" "lock"];
      };
      cursor = {
        hide-when-typing = {};
      };
    };
    target = ".config/niri/config.kdl";
  };
}
