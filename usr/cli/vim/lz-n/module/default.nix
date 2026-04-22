{ config, lib, ... }:
let
  cfg = config.my.neovim.lz-n;
in {
  options.my.neovim.lz-n = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [];
    description = "List of lz.n plugin specs.";
  };

  config = lib.mkIf (cfg != []) {
    programs.neovim.plugins = map (entry: {
      plugin = entry.plugin;
      type = "lua";
      config = let
        _1_spec = entry.spec // {"1" = entry.plugin.pname;};

        /*_1_spec_lua_str = {
          ["1"] = <pname>,
          ...
        }*/
        _1_spec_lua_str = lib.generators.toLua {} _1_spec;

        /*spec_lua_str = {
          <pname>,
          ...
        }*/
        spec_lua_str = lib.replaceString ''["1"] = '' "" _1_spec_lua_str;
      in ''
        require("lz.n").load(${spec_lua_str})
      '';
      optional = true;
    }) cfg;
  };
}
