{ pkgs, lib, config, ... }: {
  imports = [
    ./image
    ./picker/config.nix
  ];
  options = {
    my.nvim.snacks.setupArgs = lib.mkOption {
      default = "";
      type = lib.types.lines;
    };
    my.nvim.snacks.extraLuaConfig = lib.mkOption {
      default = "";
      type = lib.types.lines;
    };
  };
  config.programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.snacks-nvim.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          # Upstream fix: https://github.com/folke/snacks.nvim/pull/2999
          ./picker/tags-nomagic.patch
        ];
      });
      type = "lua";
      config = /*lua*/ ''
        require("snacks").setup({
          ${config.my.nvim.snacks.setupArgs}
          ${import ./scroll/lua.nix}
          ${import ./picker/lua.nix}
        })
      '' + config.my.nvim.snacks.extraLuaConfig;
    }];
  };
}
