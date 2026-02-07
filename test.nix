let
  pkgs = import <nixpkgs> {};
in pkgs.lib.runTests {
  test-overlays = pkgs.lib.testAllTrue [
    (pkgs?nur)
    (pkgs?pkgsu)
    (pkgs?flake-compat)
  ];
}
