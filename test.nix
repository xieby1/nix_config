let
  pkgs = import <nixpkgs> {};
in pkgs.lib.debug.throwTestFailures { failures = pkgs.lib.runTests {
  test-overlays = pkgs.lib.testAllTrue [
    (pkgs?npinsed)
    (pkgs?nur)
    (pkgs?pkgsu)
    (pkgs?flake-compat)
  ];
}; }
