let
  pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation {
  name = "child";
  propagatedBuildInputs = [
    (import ./grandchild.nix)
  ];
  dontUnpack = true;
  buildPhase = "mkdir -p $out";
  installPhase = "touch $out/miao";
}
