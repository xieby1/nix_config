# TODO: why claude is not available?
# TODO: it seems every nvim instances start a node, which consumes tons of memory (900MB per node), use lazy.nvim!
{ pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.pkgsu.vimPlugins.copilot-lua;
    type = "lua";
    config = ''
      require("copilot").setup({})
    '';
  }];
}
