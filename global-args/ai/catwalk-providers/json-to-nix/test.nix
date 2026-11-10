let
  lib = import <nixpkgs/lib>;
  catwalk = (import <npins> { input = ../../sources.json; }).catwalk;
  deepseek = import ./. "${catwalk}/internal/providers/configs/deepseek.json";
in lib.debug.throwTestFailures { failures = lib.runTests {
  test-deepseek-modules-attrs = lib.testAllTrue [
    (deepseek.models ? deepseek-v4-flash)
    (deepseek.models ? deepseek-v4-pro)
  ];
}; }
