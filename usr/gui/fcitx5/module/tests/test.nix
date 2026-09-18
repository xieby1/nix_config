let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [
        ../.
        ../../../../modules/yq-merge
      ];
      home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
      my.config-fcitx5.".config/fcitx5/conf/chttrans.conf" = {
        expr = {
          globalSection = {
            Engine = "OpenCC";
          };
          sections = {
            Hotkey."0" = "Alt+F";
          };
        };
      };
    };
  };
in pkgs.lib.runTests {
  test-onChange = let
    # TODO: modularize the test-onChange, e.g. create a standalone dummy-home generation function
    dummy-home = pkgs.runCommand "test-onChange" {} ''
      mkdir -p $out/.config/fcitx5/conf
      cd $out
      echo '[Hotkey]' > .config/fcitx5/conf/chttrans.conf
      echo '0=Miao' >> .config/fcitx5/conf/chttrans.conf
      cat > .config/fcitx5/conf/yq-merge.chttrans.conf <<EOF
      ${hm.config.home.file.".config/fcitx5/conf/chttrans.conf".text}EOF
      run() { "$@"; }
      ${hm.config.home.file.".config/fcitx5/conf/chttrans.conf".onChange}
    '';
  in {
    expr = builtins.readFile (dummy-home + /.config/fcitx5/conf/chttrans.conf);
    expected = ''
      Engine=OpenCC

      [Hotkey]
      0=Alt+F
    '';
  };
}
