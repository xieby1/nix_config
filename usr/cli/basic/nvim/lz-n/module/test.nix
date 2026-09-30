let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [./.];
      home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
      my.neovim.lz-n = [{
        plugin = pkgs.vimPlugins.copilot-lua;
        spec = {
          cmd = "Copilot";
          after = pkgs.lib.generators.mkLuaInline ''function() require("copilot").setup() end'';
        };
      }];
    };
  };
  pluginEntry = builtins.elemAt (builtins.filter (p: p ? optional && p.optional) hm.config.programs.neovim.plugins) 0;
in pkgs.lib.runTests {
  test-plugin = {
    expr = pluginEntry.plugin.pname;
    expected = "copilot.lua";
  };
  test-type = {
    expr = pluginEntry.type;
    expected = "lua";
  };
  test-optional = {
    expr = pluginEntry.optional;
    expected = true;
  };
  test-config-does-not-have-plugin = {
    expr = pkgs.lib.hasInfix ''["plugin"] ='' pluginEntry.config;
    expected = false;
  };
  test-config-has-load = {
    expr = pkgs.lib.hasInfix ''require("lz.n").load'' pluginEntry.config;
    expected = true;
  };
  test-config-has-pname = {
    expr = pkgs.lib.hasInfix ''"copilot.lua"'' pluginEntry.config;
    expected = true;
  };
  test-config-has-cmd = {
    expr = pkgs.lib.hasInfix ''["cmd"] = "Copilot"'' pluginEntry.config;
    expected = true;
  };
  test-config-has-after = {
    expr = pkgs.lib.hasInfix ''require("copilot").setup()'' pluginEntry.config;
    expected = true;
  };
}
