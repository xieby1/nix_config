{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.typst-preview-nvim;
      type = "lua";
      config = /*lua*/ ''
        require ('typst-preview').setup()
      '';
    }];
    extraLuaConfig = /*lua*/ ''
      vim.lsp.enable('tinymist')
    '';
    extraPackages = [ pkgs.tinymist ];
  };
}
