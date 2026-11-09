let
  lib = import <nixpkgs/lib>;
  npinsFun = (import ../../../npins).__functor null;
  catwalk = (npinsFun { input = ../sources.json; }).catwalk;
  providers = import ./. { inherit lib catwalk; };
in lib.runTests {
  test-providers = lib.testAllTrue [
    (providers?deepseek)
    (providers.deepseek?models)
    (providers.deepseek.models?deepseek-v4-flash)
  ];
}

