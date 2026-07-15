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
                     - cmd:     Lazy-load on command(s) (e.g. "Snacks").
                     - keys:    Lazy-load on keymap(s). Each entry is a Nix list
                                that serializes to a Lua array. Examples:
                                  keys = [ "<leader>ff" ];
                                  keys = [ [ "<leader>ff" "<cmd>lua Snacks.picker.files()<cr>" ] ];
                                  keys = [ [ "<leader>ff" "<cmd>lua Snacks.picker.files()<cr>" { desc = "Find files"; } ] ];
                     - ft:      Lazy-load on filetype(s).
                     - before:  Lua function to run before loading.
                                Must be a Lua function, not a plain string. Use:
                                  before = lib.generators.mkLuaInline "function(self) ... end";
                     - after:   Lua function to run after loading. Same as before.
                                This is where plugin setup() calls belong:
                                  after = lib.generators.mkLuaInline '''function(self) require("plugin").setup({}) end''';
                     - colorscheme: Lazy-load on colorscheme(s).
                                Set to the colorscheme name(s) (string or list of strings).
                   See https://github.com/nvim-neorocks/lz.n for full spec.

      Example:
        {
          plugin = pkgs.vimPlugins.snacks-nvim;
          spec = {
            cmd = [ "Snacks" ];
            keys = [
              [ "<leader>ff" "<cmd>lua Snacks.picker.files()<cr>" { desc = "Find files"; } ]
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
        # HACK: replaceString replaces ALL occurrences — corrupts output if any spec
        # value contains the literal ["1"] =  (e.g. in a before/after inline Lua string).
        spec_lua_str = lib.replaceString ''["1"] = '' "" _1_spec_lua_str;
      in ''
        require("lz.n").load(${spec_lua_str})
      '';
      optional = true;
    }) cfg;
  };
}
