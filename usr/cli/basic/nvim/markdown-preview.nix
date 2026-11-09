{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.markdown-preview-nvim.overrideAttrs (old: {
        postPatch = toString [
        # use cjk2ch.js
        (let
          cjk2ch_js = pkgs.fetchurl {
            url = "https://github.com/xieby1/markdown_revealjs/raw/c9c91257d06b63adcf67d3464efbc392f55677ff/share/markdown_revealjs/cjk2ch.js";
            sha256 = "0d2xjy8g89zq8677ggklfpr3f9jd8lny37lbcdqr0asvmiqjgx9x";
          };
        # 添加cjk2ch.js
        # 给混淆过的index.js打补丁（这生成代码居然直接放git，😼😼😼啧啧啧，源码是index.jsx）
        # 通过code:not(:has(span))来识别哪些code可能是ascii art
        # 在refreshContent最后，即renderDot的后面调用cjk2ch(...)
        in ''
          cp ${cjk2ch_js} app/_static/cjk2ch.js
          sed -i 's,<head>,&<script src="/_static/cjk2ch.js"></script>,' app/out/index.html
          sed -i 's,}var e;G(),;cjk2ch("code:not(:has(span))");&,' app/out/_next/static/s7O4q0ISzv1r8jtwIkXLb/pages/index.js
        '')
        # set port to 7700~7799
        ''
          sed -i 's/port = port ||.*/port = port || (7700 + Number(`''${Date.now()}`.slice(-2)))/' app/server.js
        ''
        # set line-height of <pre></pre>
        ''
          sed -i 's/line-height: 1.45;/line-height: 1em;/' app/_static/markdown.css
        ''
        # upgrade mermaid
        (let
          mermaid_js = pkgs.fetchurl {
            url = "https://cdn.jsdelivr.net/npm/mermaid@11.9.0/dist/mermaid.min.js";
            sha256 = "1658hsyxrg9sh3nmafsisiylsw7z436dznpgv8akhdhp84vx8ghb";
          };
        in ''
          cp ${mermaid_js} app/_static/mermaid.min.js
        '')];
      });
      type = "viml";
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
