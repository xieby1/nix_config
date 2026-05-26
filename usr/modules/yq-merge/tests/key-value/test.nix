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
    dummy-home = pkgs.runCommand "test-onChange" {} ''
      mkdir -p $out/.config
      cd $out
      echo miao=1 > .config/env
      echo zhi=1 >> .config/env
      cat > .config/yq-merge.env <<EOF
      ${hm.config.home.file.".config/env".text}EOF
      run() { "$@"; }
      ${hm.config.home.file.".config/env".onChange}
      diff -u <(printf 'miao=miao miao!\nzhi=1\nwang=wang~\n') .config/env
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
