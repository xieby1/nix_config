let
  lib = import <nixpkgs/lib>;
  npinsFun = (import ../../../../npins).__functor null;
  catwalk = (npinsFun { input = ../../sources.json; }).catwalk;
  deepseek = import ./. "${catwalk}/internal/providers/configs/deepseek.json";
in lib.runTests {
  test-deepseek-modules-attrs = lib.testAllTrue [
    (deepseek.models ? deepseek-v4-flash)
    (deepseek.models ? deepseek-v4-pro)
  ];
}
