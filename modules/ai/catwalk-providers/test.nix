let
  pkgs = import <nixpkgs> {};
  providers = import ./. pkgs;
in pkgs.lib.runTests {
  test-providers = pkgs.lib.testAllTrue [
    (providers?deepseek)
    (providers.deepseek?models)
    (providers.deepseek.models?deepseek-chat)
    (providers.minimax-china.models?"MiniMax-M2.7")
  ];
}

