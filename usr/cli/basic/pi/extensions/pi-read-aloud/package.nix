{ pkgs ? import <nixpkgs> {} }:
pkgs.buildNpmPackage {
  pname = "pi-read-aloud";
  version = "0.1.0";
  src = ./.;
  npmDepsHash = "sha256-lqMnKBGsJqKKtu4LMEyZ153qec+nxaOOeGjK5rIc67I=";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];
}
