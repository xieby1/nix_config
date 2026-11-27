let
  pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation {
  name = "grandchild";
  dontUnpack = true;
  propagatedBuildInputs = [
    pkgs.hello
  ];
  buildPhase = "mkdir -p $out";
  installPhase = "touch $out/miao";
}
