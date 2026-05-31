{ pkgs, ... }: {
  imports = [
    ./image/config.nix
    ./picker/config.nix
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("snacks").setup({
          ${import ./image/lua.nix}
          ${import ./scroll/lua.nix}
          ${import ./picker/lua.nix}
        })
      '';
    }];
  };
}
