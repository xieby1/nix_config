# vestige lurks in background consuming 1GB memory!
{ pkgs, ... }: let
  vestige = import ./package.nix;
in {
  home.packages = [
    vestige
    (pkgs.writeShellScriptBin "vestige-list" ''
      ${vestige}/bin/vestige export /dev/stderr \
        2> >(${pkgs.yq-go}/bin/yq -P 'map(pick(["nodeType", "tags", "content"]))') \
        > /dev/null
    '')
  ];
  cachix_packages = [vestige];
}
