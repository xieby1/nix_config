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

        " Use chromium-like browser to open rendered markdown instead of firefox,
        " because firefox only copy css in selected region, causing lost of styles!
        " See same bug report here:
        " https://discourse.mozilla.org/t/copy-rich-text-from-firefox-does-not-capture-style/97862/3
        function OpenMarkdownPreview (url)
          " run chromium in app mode in background
          execute "silent ! chromium --app='" . a:url . "' &"
        endfunction
        let g:mkdp_browserfunc = 'OpenMarkdownPreview'
      '';
    }];
  };
}
