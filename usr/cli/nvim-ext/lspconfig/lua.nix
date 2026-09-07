{ pkgs, ... }: {
  programs.neovim={
    extraLuaConfig = /*lua*/''
      -- ~/.local/share/emmylua_ls/logs/ is huge, over 13GB now, so disable logs completely.
      vim.lsp.config('emmylua_ls', {
        cmd = { 'emmylua_ls', '--log-path', 'none' },
      })
      vim.lsp.enable('emmylua_ls')
    '';
    extraPackages = [ pkgs.emmylua-ls ];
  };
  home.packages = [ pkgs.emmylua-check ];
  cachix_packages = [ pkgs.emmylua-ls pkgs.emmylua-check ];
}
