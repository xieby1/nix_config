{ lib, ... }:
let
  sources = import <npins> {input = ./sources.json;};
  depkgs = import sources.nixpkgs {};
in {
  imports = [
    ./niri
    # ./dms
    (lib.modules.importApply ./noctalia { inherit depkgs; })
  ];
}
