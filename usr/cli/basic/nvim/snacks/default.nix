{ pkgs, lib, config, ... }: {
  imports = [
    ./image
    ./picker
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
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("snacks").setup({
          ${config.my.nvim.snacks.setupArgs}
          ${import ./scroll/lua.nix}
        })
      '' + config.my.nvim.snacks.extraLuaConfig;
    }];
  };
}
