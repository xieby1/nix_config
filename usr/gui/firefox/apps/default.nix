#MC # firefox-apps
#MC
#MC ## Comparison of chromium-based browsers and firefox
#MC
#MC * list windows: `wmctrl -l`
#MC * list windows properties: `xprop -name <WIN_NAME> [PROP]`
#MC
#MC second instance of chrome ignores `--class`
#MC * bing: chrome wm_class new instance
#MC   * https://superuser.com/questions/1457060/how-can-you-start-two-chrome-windows-with-different-wm-class-attributes
#MC     * https://issues.chromium.org/issues/40172351
#MC     * 目前看来最好的方法：--user-data-dir
#MC     * firefox类似，用不同的profile
#MC
#MC https://superuser.com/questions/1770285/custom-firefox-profiles-with-different-wm-class-and-icons
#MC
#MC set WM_CLASS
#MC * https://stackoverflow.com/questions/36650865/set-wm-class-with-wnck-xprop-or-something-else
#MC 能正常设置kitty的WM_CLASS，但是为什么chrome不行？
#MC
#MC 所以选择firefox！
{ config, ... }: {
  imports = [
    ./module.nix
  ];

  firefox-apps = [{
    name = "todo";
    url = "https://to-do.live.com/";
    desktopEntryExtras = {
      name = "Microsoft To Do";
    };
  }{
    name = "calendar";
    url = "https://outlook.live.com/calendar";
    desktopEntryExtras = {
      name = "Microsoft Calendar";
    };
  }{
    name = "outlook";
    url = "https://outlook.live.com";
    desktopEntryExtras = {
      name = "Microsoft Outlook";
    };
  }{
    name = "webweixin";
    url = "https://wx.qq.com";
    desktopEntryExtras = {
      name = "网页微信";
      genericName = "weixin";
    };
  }{
    name = "my_cheatsheet_html";
    url = "${config.home.homeDirectory}/Documents/Tech/my_cheatsheet.html";
    keybinding = "<Alt>space";
    desktopEntryExtras = {
      name = "Cheatsheet HTML";
      genericName = "cheatsheet";
      icon = builtins.toFile "cheatsheet.svg" ''
        <svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
          <rect width="100%" height="100%" rx="20%" ry="20%" fill="#666666"/>
          <text x="50%" y="50%" text-anchor="middle" dominant-baseline="middle" font-size="18" font-weight="bold" fill="#F5F5F5">
            <tspan x="50%" dy="-0.6em">CS</tspan>
            <tspan x="50%" dy="1.2em">html</tspan>
          </text>
        </svg>
      '';
    };
  }{
    name = "bing_dict";
    url = "https://cn.bing.com/dict";
    keybinding = "<Alt>b";
    desktopEntryExtras = {
      name = "Bing Dict";
      genericName = "dictionary";
    };
  }{
    name = "riyucidian";
    url = "https://dict.hjenglish.com/jp";
    keybinding = "<Alt>j";
    desktopEntryExtras = {
      name = "日语词典";
    };
  }{
    name = "devdocs";
    url = "https://devdocs.io";
    desktopEntryExtras = {
      name = "DevDocs";
    };
  }(let
    metacubexd = builtins.fetchTarball "https://github.com/MetaCubeX/metacubexd/archive/gh-pages.zip";
  in {
    name = "clash";
    url = "${metacubexd}/index.html";
    desktopEntryExtras = {
      icon = "${metacubexd}/pwa-192x192.png";
    };
  }){
    name = "ai";
    url = "https://web.chatboxai.app";
    keybinding = "<Alt>a";
    desktopEntryExtras = {
      name = "AI Chatbox";
    };
  }];
}
