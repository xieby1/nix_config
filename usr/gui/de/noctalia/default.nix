{ depkgs }: # local args
{ ... }: let
  noctalia = depkgs.noctalia.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./calendar-event-titles.patch ];
  });
in {
  imports = [ ./settings.nix ./pi-noctalia ];
  home.packages = [
    noctalia
  ];
  cachix_packages = [ noctalia ];
}
