let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  providers = builtins.fromJSON (builtins.readFile (pkgs.callPackage ./. {}));
in lib.debug.throwTestFailures { failures = lib.runTests {
  test-openai = {
    expr = providers.openai.models."gpt-6.1-sol".limit.context;
    expected = 1050000;
  };
  test-deepseek-serving-alias = {
    expr = providers.deepseek.models.deepseek-flash.canonical_model_id;
    expected = "deepseek/deepseek-v4.1-flash-1017";
  };
  test-kimi-coding = {
    expr = providers.kimi-code-plan-cn.models."k3.1-pro".canonical_model_id;
    expected = "moonshotai/kimi-k3.1-pro";
  };
}; }
