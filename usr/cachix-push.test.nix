let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  hasPushHook = settings: let
    cfg = (import <home-manager/modules> {
      inherit pkgs;
      configuration = {
        imports = [ ./cachix-push.nix ];
        home = { username = "dummy"; homeDirectory = "/tmp/cachix-push-test"; stateVersion = "25.11"; };
        # Only file existence is checked; the activation script is never run.
        cachix_dhall = toString ./cachix-push.nix;
      } // settings;
    }).config;
  in cfg.home.activation ? cachix_push;
in lib.runTests {
  test-existing-config-enables-push = {
    expr = hasPushHook {};
    expected = true;
  };
  test-missing-config-skips-push = {
    expr = hasPushHook { cachix_dhall = "${toString ./cachix-push.nix}.missing"; };
    expected = false;
  };
  test-empty-packages-skips-push = {
    expr = hasPushHook { cachix_packages = lib.mkForce []; };
    expected = false;
  };
}
