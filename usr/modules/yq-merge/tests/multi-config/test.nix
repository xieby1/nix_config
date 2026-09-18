let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [
        ../../.
        # config 1
        {
          yq-merge.".config/miao.json" = {
            generator = builtins.toJSON;
            expr = { wang = "wang wang!"; };
          };
        }
        # config 2
        {
          yq-merge.".config/miao.json" = {
            generator = builtins.toJSON;
            expr = { miao = "miao miao!"; };
            preOnChange = ''
              echo wang
            '';
            postOnChange = ''
              echo zhi
            '';
          };
        }
      ];
      home = {stateVersion="25.11"; username="dummy"; homeDirectory="/dummy";};
    };
  };
in pkgs.lib.runTests {
  # The `generator` type must not be `lib.types.functionTo lib.types.lines`.
  # If it were, home-manager would merge the generated text from multiple configs.
  # This test verifies that the generator outputs are not merged.
  test-multi-config = {
    expr = hm.config.home.file.".config/miao.json".text;
    expected = "{\"miao\":\"miao miao!\",\"wang\":\"wang wang!\"}";
  };
}
