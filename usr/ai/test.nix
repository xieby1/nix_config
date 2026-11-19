# Run with nix-instantiate --eval --strict --read-write-mode global-args/ai/test.nix.
let
  lib = import <nixpkgs/lib>;
  raw = {
    openai.models.large.limit = { context = 1050000; input = 922000; output = 128000; };
    other.models = {
      capped.limit = { context = 100000; input = 10000; output = 1000; };
      no-input.limit = { context = 100000; output = 1000; };
    };
  };
  api = (import ./. {
    inherit lib;
    pkgs.callPackage = _: _: builtins.toFile "models-dev-api-test.json" (builtins.toJSON raw);
  })._module.args.ai.models-dev-providers;
in lib.debug.throwTestFailures { failures = lib.runTests {
  test-working-contexts-across-providers = {
    expr = builtins.mapAttrs (_: provider:
      builtins.mapAttrs (_: model: model.workingContext) provider.models
    ) api;
    expected = {
      openai.large = 350000;
      other = { capped = 10000; no-input = 33333; };
    };
  };
  test-preserve-upstream-metadata = {
    expr = builtins.mapAttrs (_: provider: provider // {
      models = builtins.mapAttrs (_: model: builtins.removeAttrs model [ "workingContext" ]) provider.models;
    }) api;
    expected = raw;
  };
}; }
