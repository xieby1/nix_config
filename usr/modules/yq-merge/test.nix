let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [./.];
      home = {stateVersion="25.11"; username="dummy"; homeDirectory="/dummy";};
      # Config to be tested
      yq-merge.".config/miao.json" = {
        text = "miao miao!";
        preOnChange = ''
          echo wang
        '';
        postOnChange = ''
          echo zhi
        '';
      };
    };
  };
in pkgs.lib.runTests {
  test-target = {
    expr = hm.config.home.file.".config/miao.json".target;
    expected = ".config/yq-merge.miao.json";
  };
  test-text = {
    expr = hm.config.home.file.".config/miao.json".text;
    expected = "miao miao!";
  };
  test-onChange = {
    expr = hm.config.home.file.".config/miao.json".onChange != "";
    expected = true;
  };
  test-preOnChange = {
    expr = pkgs.lib.hasInfix "echo wang" hm.config.home.file.".config/miao.json".onChange;
    expected = true;
  };
  test-postOnChange = {
    expr = pkgs.lib.hasInfix "echo zhi" hm.config.home.file.".config/miao.json".onChange;
    expected = true;
  };
}
