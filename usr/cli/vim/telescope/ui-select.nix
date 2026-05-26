{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
    plugin = pkgs.vimPlugins.telescope-ui-select-nvim;
    type = "lua";
    config = /*lua*/ ''
      require('telescope').setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
          },
        },
      }
      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    '';
    }];
  };
}
