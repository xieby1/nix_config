let
  lib = import <nixpkgs/lib>;
  args = import ./. { inherit lib; };
in lib.debug.throwTestFailures { failures = lib.runTests {
  test-nix-on-droid-flag = {
    expr = args.isNixOnDroid or null;
    expected = builtins.getEnv "USER" == "nix-on-droid";
  };
}; }
