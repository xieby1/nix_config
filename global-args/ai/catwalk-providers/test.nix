let
  lib = import <nixpkgs/lib>;
  catwalk = (import <npins> { input = ../sources.json; }).catwalk;
  providers = import ./. { inherit lib catwalk; };
in lib.debug.throwTestFailures { failures = lib.runTests {
  test-providers = lib.testAllTrue [
    (providers?deepseek)
    (providers.deepseek?models)
    (providers.deepseek.models?deepseek-v4-flash)
  ];
}; }

