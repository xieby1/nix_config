{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.typst-preview-nvim;
      type = "lua";
      config = /*lua*/ ''
        require ('typst-preview').setup({
          open_cmd = "single-tab %s",
        })
      '';
    }];
    extraLuaConfig = /*lua*/ ''
      vim.lsp.enable('tinymist')
    '';
    extraPackages = [ pkgs.tinymist ];
  };
}
