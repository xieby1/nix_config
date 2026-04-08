# TODO: why claude is not available?
{ pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.pkgsu.vimPlugins.copilot-lua;
    type = "lua";
    config = ''
      require("copilot").setup({})
    '';
  }];
}
