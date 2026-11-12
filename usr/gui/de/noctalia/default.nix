{ depkgs }: # local args
{ ... }: let
  noctalia = depkgs.noctalia.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./calendar-event-titles.patch ];
  });
in {
  imports = [ ./settings.nix ];
  home.packages = [
    noctalia
  ];
  cachix_packages = [ noctalia ];
}
