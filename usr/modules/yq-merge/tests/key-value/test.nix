let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [../../.];
      home = {stateVersion="25.11"; username="dummy"; homeDirectory="/dummy";};
      # Config to be tested
      yq-merge.".config/miao.json" = {
        generator = pkgs.lib.generators.toKeyValue {};
        expr = { miao = "miao miao!"; wang = "wang~"; };
        yqExtraArgs = "-o shell";
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
    expected = "miao=miao miao!\nwang=wang~\n";
  };
}
