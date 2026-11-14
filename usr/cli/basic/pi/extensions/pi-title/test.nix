let
  pkgs = import <nixpkgs> {};
  sources = import <npins> {input = ../../sources.json;};
  module = import ./default.nix {src = sources.pi-title + "/extensions/title";} {
    inherit pkgs;
    inherit (pkgs) lib;
    ai.default_small = {
      provider = "test-provider";
      model = { id = "test-model"; reasoning_levels = [ "low" ]; };
    };
  };
  root = module.home.file.".pi/agent/extensions/pi-title".source;
in pkgs.lib.debug.throwTestFailures { failures = pkgs.lib.runTests {
  test-installed-entrypoint = {
    expr = builtins.pathExists "${root}/index.ts";
    expected = true;
  };
  test-runtime-dependencies = {
    expr = builtins.attrNames (builtins.fromJSON (builtins.readFile "${root}/package.json")).dependencies;
    expected = [ "jsonc-parser" ];
  };
  test-title-settings = {
    expr = module.yq-merge.".pi/agent/pi-title.jsonc".expr;
    expected = { refreshTurns = 5; model = "test-provider/test-model:low"; };
  };
}; }
