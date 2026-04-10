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
      config = ''
        require("lz.n").load(
          vim.tbl_extend("force",
            {"${entry.plugin.pname}"},
            ${lib.generators.toLua {} entry.spec}
          )
        )
      '';
      optional = true;
    }) cfg;
  };
}
