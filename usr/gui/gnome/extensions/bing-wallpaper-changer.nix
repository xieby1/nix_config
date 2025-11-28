#MC # BingWallpaper
{ pkgs, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.bing-wallpaper-changer
    # random-wallpaper-wip-v3
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "BingWallpaper@ineffable-gmail.com"
        # "randomwallpaper@iflow.space"
      ];
    };
    "org/gnome/shell/extensions/bingwallpaper" = {
      market="zh-CN";
      delete-previous=true;
      download-folder="/tmp/pictures";
    };
    # "org/gnome/shell/extensions/space-iflow-randomwallpaper" = {
    #   auto-fetch = true;
    #   change-lock-screen = true;
    #   hours = 8;
    #   minutes = 29;
    #   source = "genericJSON";
    #   # source = "wallhaven";
    # };
    # "org/gnome/shell/extensions/space-iflow-randomwallpaper/genericJSON" = {
    #   generic-json-request-url = "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN";
    #   generic-json-response-path = "$.images[0].url";
    #   generic-json-url-prefix = "http://www.bing.com";
    # };
    # "org/gnome/shell/extensions/space-iflow-randomwallpaper/wallhaven" ={
    #   wallhaven-keyword="cardcaptor sakura";
    # };
  };
}
