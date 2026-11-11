{ config, pkgs, ... }: {
  home.file.niri_config = {
    text = config.lib.generators.toKDL {} {
      _children = [
        { include = "./dms/colors.kdl"; }
        { include = "./dms/cursor.kdl"; }
        { include = "./dms/alttab.kdl"; }
        { include = "./dms/wpblur.kdl"; }
        # { include = "./dms/layout.kdl"; }
        { include = "./dms/outputs.kdl"; }
        { include = "./dms/binds.kdl"; }
        {
          # TODO: move to evolution
          window-rule = {
            match._props.app-id="evolution-alarm-notify";
            open-floating = true;
            default-window-height = { proportion = 0.3; };
            default-column-width = { proportion = 0.3; };
          };
        }
      ];

      # Ghostty's OSC 777 notification action selects the right Pi tab, but
      # niri 26.04 rejects the window activation under its default serial check.
      # Trade-off: apps can steal focus with invalid-serial tokens. This niri
      # debug option is not covered by its config stability policy.
      # Remove when clicking a Pi notification from another workspace and tab
      # works without this flag, or replace it with a Ghostty-only
      # on-xdg-activate rule once our niri supports that rule (26.04 does not).
      debug.honor-xdg-activation-with-invalid-serial = {};

      animations.window-focus = {
        on-focus = {};
        scale = 0.9;
        duration-ms = 300;
        curve = "ease-out-cubic";
      };
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
