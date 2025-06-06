{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.markdown-preview-nvim.overrideAttrs (old: {
        # set port to 7700~7799
        postPatch = ''
          sed -i 's/port = port ||.*/port = port || (7700 + Number(`''${Date.now()}`.slice(-2)))/' app/server.js
        '';
      });
      config = ''
        " allow LAN
        let g:mkdp_open_to_the_world = 1
        let g:mkdp_theme = 'light'
      '';
    }];
  };
}
