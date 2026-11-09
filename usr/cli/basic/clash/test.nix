let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  evaluate = settings: import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [
        ../../../cachix-push.nix
        ../../../yq-merge
        ../../../syncthing-gist-ignore.nix
        ./.
        settings
      ];
      _module.args.isNixOnDroid = false;
      home = { username = "test"; homeDirectory = "/tmp/mihomo-test"; stateVersion = "25.05"; };
    };
  };
  basic = evaluate {};
  overridden = evaluate { proxyPort = 19090; };
in lib.runTests {
  test-default-port = {
    expr = basic.config.proxyPort;
    expected = 8889;
  };
  test-overridden-port = {
    expr = overridden.config.proxyPort;
    expected = 19090;
  };
  test-string-port-is-rejected = {
    expr = basic.options.proxyPort.type.check "8889";
    expected = false;
  };
  test-overridden-port-reaches-client-environment = {
    expr = lib.hasInfix ''HTTP_PROXY="http://127.0.0.1:19090"'' overridden.config.programs.zsh.envExtra;
    expected = true;
  };
}
