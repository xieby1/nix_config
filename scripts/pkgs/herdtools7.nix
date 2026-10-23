let
 pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  name = "herdtool7";
  src = pkgs.fetchFromGitHub {
    owner = "herd";
    repo = "herdtools7";
    rev = "7c36d32e7e0dd546296ddd05c5279ae42665a4cf";
    hash = "sha256-gGxM2JYZwbtveQu3PRMKvr4XePJA0jtQK9WUEpCTn8c=";
  };
  buildInputs = [
    pkgs.which
    pkgs.ocamlPackages.ocaml
    pkgs.ocamlPackages.findlib
    pkgs.ocamlPackages.dune_3
    pkgs.ocamlPackages.menhir
    pkgs.ocamlPackages.menhirLib
    pkgs.ocamlPackages.zarith
  ];
  makeFlags = [
    "PREFIX=$(out)"
  ];
}
