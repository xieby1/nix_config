let
  pkgs = import <nixpkgs> {};
in pkgs.lib.runTests {
  test-provider-module = let
    content = builtins.readFile (import ./default.nix {
      inherit (pkgs) lib;
      catwalk-provider = {
        id = "test-provider";
        api_endpoint = "https://api.example.com";
        api_key = "test-key";
        models = {
          "model-1" = {
            id = "model-1";
            name = "Test Model";
            can_reason = true;
            cost_per_1m_in = 0.5;
            cost_per_1m_out = 1.5;
            cost_per_1m_in_cached = 0.1;
            cost_per_1m_out_cached = 0.3;
            context_window = 100000;
            default_max_tokens = 4096;
          };
        };
      };
      api = "anthropic-messages";
      runCommand = pkgs.runCommand;
      prettier = pkgs.prettier;
    });
  in pkgs.lib.testAllTrue [
    (pkgs.lib.hasInfix "registerProvider" content)
    (pkgs.lib.hasInfix "https://api.example.com" content)
    (pkgs.lib.hasInfix "test-key" content)
    (pkgs.lib.hasInfix "anthropic-messages" content)
    (pkgs.lib.hasInfix "model-1" content)
    (pkgs.lib.hasInfix "contextWindow: 100000" content)
  ];

  test-api-assertion = {
    expr = builtins.tryEval (import ./default.nix {
      inherit (pkgs) lib;
      catwalk-provider = {
        id = "test";
        api_endpoint = "";
        api_key = "";
        models = {};
      };
      api = "invalid-api";
      runCommand = pkgs.runCommand;
      prettier = pkgs.prettier;
    });
    expected = { success = false; value = false; };
  };
}
