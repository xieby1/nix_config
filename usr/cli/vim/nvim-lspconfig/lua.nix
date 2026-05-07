{ pkgs, ... }: {
  programs.neovim={
    extraLuaConfig = "vim.lsp.enable('emmylua_ls')\n";
    extraPackages = [
      (pkgs.emmylua-ls.overrideAttrs(old: {
        # TODO: The symlink support has been added to upstream:
        #       https://github.com/EmmyLuaLs/emmylua-analyzer-rust/commit/b087ffe4f47cdc2c48c99da16b33745dbae1a587
        #       Remove the following patch once nixpkgs stable include it.
        postPatch = (old.postPatch or "") + ''
          grep 'follow_links(true)' crates/emmylua_code_analysis/src/vfs/loader.rs && exit
          sed -i '/WalkDir::new(root)/a\.follow_links(true)' crates/emmylua_code_analysis/src/vfs/loader.rs
        '';
      }))
    ];
  };
}
