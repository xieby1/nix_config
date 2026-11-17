{ enableExtendedCLI }:
{ config, lib, pkgs, ... }:
let
  npinsed = import <npins> {input=./sources.json;};
  pipkgs = import ./pkgs.nix {src = npinsed.nixpkgs;};
in {
  imports = [
    (lib.modules.importApply ./extensions {
      inherit enableExtendedCLI pipkgs;
      sources = npinsed;
    })
    ./providers
  ] ++ lib.optionals enableExtendedCLI [
    (lib.modules.importApply ./pi-web {src = npinsed.pi-web;})
  ];
  home.packages = [
    # Include session-file size (S5.5M) in Pi's built-in footer stats line.
    (pipkgs.pi-coding-agent.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./footer-session-size.patch
        # Let extension widgets scroll with the fullscreen transcript instead of pinning them to the input dock.
        ./fullscreen-scrollable-widgets.patch
      ];
    }))
  ];

  yq-merge.".pi/agent/settings.json" = {
    generator = builtins.toJSON;
    expr = {
      # Only fullscreen provides prompt navigation.
      tuiMode = "fullscreen";
      fullscreenWheelScrollLines = 1;
    };
  };

  yq-merge.".pi/agent/keybindings.json" = {
    generator = builtins.toJSON;
    expr = {
      "tui.altScreen.previousPrompt" = "alt+shift+up";
      "tui.altScreen.nextPrompt" = "alt+shift+down";
      "tui.altScreen.search" = "alt+shift+f";
      "tui.altScreen.top" = "alt+shift+pageUp";
      "tui.altScreen.bottom" = "alt+shift+pageDown";
    };
  };

  home.file.".pi/agent/sessions".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/sessions;
}
