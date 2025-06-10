{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.markdown-preview-nvim.overrideAttrs (old: {
        postPatch = toString [
        # set port to 7700~7799
        ''
          sed -i 's/port = port ||.*/port = port || (7700 + Number(`''${Date.now()}`.slice(-2)))/' app/server.js
        ''
        # set line-height of <pre></pre>
        ''
          sed -i 's/line-height: 1.45;/line-height: 1em;/' app/_static/markdown.css
        ''];
      });
      config = ''
        " allow LAN
        let g:mkdp_open_to_the_world = 1
        let g:mkdp_theme = 'light'
      '';
    }];
  };
}
