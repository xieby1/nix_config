{ lib, ... }:
let
  sources = import <npins> {input = ./sources.json;};
  depkgs = import sources.nixpkgs {};
in {
  imports = [
    (lib.modules.importApply ./niri { inherit depkgs; })
    ./dms
  ];
}
