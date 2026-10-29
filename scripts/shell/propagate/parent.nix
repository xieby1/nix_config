let
  pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation {
  name = "parent";
  propagatedBuildInputs = [
    (import ./child.nix)
  ];
  dontUnpack = true;
  buildPhase = "mkdir -p $out";
  installPhase = "touch $out/miao";
}
