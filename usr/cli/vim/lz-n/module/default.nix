{ config, lib, ... }:
let
  cfg = config.my.neovim.lz-n;
in {
  options.my.neovim.lz-n = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [];
    description = ''
      List of lz.n plugin specs.

      Each element is an attribute set with the following keys:
        - plugin:  The Nix package of the Neovim plugin (required).
        - spec:    Additional lz.n spec attributes (optional).
                   Common attributes include:
                     - event:   Lazy-load on event(s) (e.g. "BufRead").
                     - cmd:     Lazy-load on command(s) (e.g. "Telescope").
                     - keys:    Lazy-load on keymap(s). Each entry is a Nix list
                                that serializes to a Lua array. Examples:
                                  keys = [ "<leader>ff" ];
                                  keys = [ [ "<leader>ff" "<cmd>Telescope find_files<cr>" ] ];
                                  keys = [ [ "<leader>ff" "<cmd>Telescope find_files<cr>" { desc = "Find files"; } ] ];
                     - ft:      Lazy-load on filetype(s).
                     - before:  Lua code to run before loading.
                     - after:   Lua code to run after loading.
                     - dep:     List of plugins this depends on.
                     - colorscheme: Set to true for colorscheme plugins.
                   See https://github.com/nvim-neorocks/lz.n for full spec.

      Example:
        {
          plugin = pkgs.vimPlugins.telescope-nvim;
          spec = {
            cmd = [ "Telescope" ];
            keys = [
              [ "<leader>ff" "<cmd>Telescope find_files<cr>" { desc = "Find files"; } ]
            ];
          };
        }
    '';
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
