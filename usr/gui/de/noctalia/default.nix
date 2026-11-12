{ depkgs }: # local args
{ ... }: {
  imports = [ ./settings.nix ];
  home.packages = [
    (depkgs.noctalia.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ./calendar-event-titles.patch ];
    }))
  ];
}
