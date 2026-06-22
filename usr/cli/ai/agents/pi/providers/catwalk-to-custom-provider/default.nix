catwalk:
{ pkgs, ...}: {
  home.file.".pi/agent/extensions/${catwalk.id}.ts".source = pkgs.callPackage ./provider.ts {} catwalk;
}
