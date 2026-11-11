{ depkgs }: # local args
{ ... }: {
  imports = [ ./settings.nix ];
  home.packages = [
    depkgs.noctalia
  ];
}
