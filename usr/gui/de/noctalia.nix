{ depkgs }: # local args
{ ... }: {
  home.packages = [
    depkgs.noctalia
  ];
}
