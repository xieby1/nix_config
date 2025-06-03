{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.markdown-preview-nvim;
      config = ''
        " ascii code for MD
        let g:mkdp_port = '7768'
        " allow LAN
        let g:mkdp_open_to_the_world = 1
        let g:mkdp_theme = 'light'
      '';
    }];
  };
}
