{ pkgs, ... }: let
  # TODO: The symlink support has been added to upstream:
  #       https://github.com/EmmyLuaLs/emmylua-analyzer-rust/commit/b087ffe4f47cdc2c48c99da16b33745dbae1a587
  #       Remove the following patch once nixpkgs stable include it.
  followLinksPatch = old: {
    postPatch = (old.postPatch or "") + ''
      grep 'follow_links(true)' crates/emmylua_code_analysis/src/vfs/loader.rs && exit
      sed -i '/WalkDir::new(root)/a\.follow_links(true)' crates/emmylua_code_analysis/src/vfs/loader.rs
    '';
  };
  emmylua-ls = pkgs.emmylua-ls.overrideAttrs followLinksPatch;
  emmylua-check = pkgs.emmylua-check.overrideAttrs followLinksPatch;
in {
  programs.neovim={
    extraLuaConfig = /*lua*/''
      -- ~/.local/share/emmylua_ls/logs/ is huge, over 13GB now, so disable logs completely.
      vim.lsp.config('emmylua_ls', {
        cmd = { 'emmylua_ls', '--log-path', 'none' },
      })
      vim.lsp.enable('emmylua_ls')
    '';
    extraPackages = [ emmylua-ls ];
  };
  home.packages = [ emmylua-check ];
  cachix_packages = [ emmylua-ls emmylua-check ];
}
