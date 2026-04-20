{ pkgs, lib, ... }: {
  programs.neovim = {
    # nui, plenary and libgit2 have been added in pkgs/applications/editors/vim/plugins/overrides.nix
    # so we do not need to add them here again.
    plugins = [ pkgs.vimPlugins.nvim-web-devicons ];
  };
  my.neovim.lz-n = [{
    plugin = pkgs.vimPlugins.fugit2-nvim.overrideAttrs (old: {
      # Since fugit2 does not support customizing key bindings,
      # I patch them directly in the source code.
      postPatch = old.postPatch + ''
        sed -i 's/"h",/{"h", "<left>" },/g' lua/fugit2/view/git_status.lua
        sed -i 's/"l",/{"l", "<right>"},/g' lua/fugit2/view/git_status.lua
      '';
    });
    spec = {
      cmd = ["Fugit2" "Fugit2Diff" "Fugit2Graph" "Fugit2Rebase"];
      after = lib.generators.mkLuaInline ''
        function() require("fugit2").setup({
          width = "95%",
          max_width = "95%",
          height = "95%",
          show_patch = true,
        }) end
      '';
    };
  }];
}
