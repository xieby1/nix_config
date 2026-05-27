let
  pkgs = import <nixpkgs> {};
  deepseek = import ./. "${pkgs.npinsed.ai.catwalk}/internal/providers/configs/deepseek.json";
in pkgs.lib.runTests {
  test-deepseek-modules-attrs = pkgs.lib.testAllTrue [
    (deepseek.models ? deepseek-chat)
    (deepseek.models ? deepseek-reasoner)
  ];
}
