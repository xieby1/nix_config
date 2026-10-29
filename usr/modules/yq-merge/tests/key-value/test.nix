let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [../../.];
      home = {stateVersion="25.11"; username="dummy"; homeDirectory="/dummy";};
      # Config to be tested
      yq-merge.".config/env" = {
        generator = pkgs.lib.generators.toKeyValue {};
        expr = { miao = "miao miao!"; wang = "wang~"; };
        yqExtraArgs = "-p props -o props --properties-separator='='";
      };
    };
  };
in pkgs.lib.runTests {
  test-target = {
    expr = hm.config.home.file.".config/env".target;
    expected = ".config/yq-merge.env";
  };
  test-text = {
    expr = hm.config.home.file.".config/env".text;
    expected = "miao=miao miao!\nwang=wang~\n";
  };
  test-onChange = let
    # TODO: modularize the test-onChange, e.g. create a standalone dummy-home generation function
    dummy-home = pkgs.runCommand "test-onChange" {} ''
      mkdir -p $out/.config
      cd $out
      echo miao=1 > .config/env
      echo zhi=1 >> .config/env
      cat > .config/yq-merge.env <<EOF
      ${hm.config.home.file.".config/env".text}EOF
      run() { "$@"; }
      ${hm.config.home.file.".config/env".onChange}
    '';
  in {
    expr = builtins.readFile (dummy-home + /.config/env);
    expected = ''
      miao=miao miao!
      zhi=1
      wang=wang~
    '';
  };
}
