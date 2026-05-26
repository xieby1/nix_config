{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.telescope-live-grep-args-nvim;
      type = "lua";
      config = /*lua*/ ''
        require('telescope').load_extension("live_grep_args")
        vim.keymap.set('n', '<space>g', function() require("telescope").extensions.live_grep_args.live_grep_args({search_dirs={require"telescope.utils".buffer_dir()}}) end)
        vim.keymap.set('n', '<space>G', require("telescope").extensions.live_grep_args.live_grep_args)
      '';
    }];
  };
}
