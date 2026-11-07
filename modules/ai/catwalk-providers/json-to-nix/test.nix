let
  pkgs = import <nixpkgs> {};
  deepseek = import ./. "${pkgs.npinsed.ai.catwalk}/internal/providers/configs/deepseek.json";
in pkgs.lib.runTests {
  test-deepseek-modules-attrs = pkgs.lib.testAllTrue [
    (deepseek.models ? deepseek-v4-flash)
    (deepseek.models ? deepseek-v4-pro)
  ];
}
