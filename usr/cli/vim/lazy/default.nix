{ pkgs, lib, ... }: {
  # Load lazy as last. Or the require after lazy may fail.
  # TODO: remove mkOrder, after all plugin are managed by lazy.
  programs.neovim.plugins = lib.mkOrder 2000 [{
    plugin = pkgs.vimPlugins.lazy-nvim;
    type = "lua";
    config = /*lua*/ ''
      require("lazy").setup({
        spec = {
          { import = "plugins" },
        },
        -- Lazy-nvim by default will set packpath and rtp, so non-lazy plugins do not work!
        -- So here we configure lazy to not reset packpath and rtp.
        -- TODO: remove these constraints.
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
          },
        },
      })
    '';
  }];
}
