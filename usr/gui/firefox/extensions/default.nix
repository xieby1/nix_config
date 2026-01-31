{ pkgs, ... }: {
  # How to self package a firefox extension?
  # 1. Add the addon to firefox manually (by firefox addon store or ...)
  # 2. Get needed info by ~/.mozilla/firefox/xieby1/extensions.json
  imports = [
    ./module.nix

    ./sidebery.nix
    ./darkreader.nix
    ./smartproxy.nix
    ./smart-toc.nix
    ./brotab.nix
    ./vimium.nix
    ./chrome-mask.nix
  ];

  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        # 😾😾😾 Chinese users cannot use ad block extensions
        # https://discourse.mozilla.org/t/chinese-users-cant-use-ad-blocker-extensions/94823
        ublock-origin
        auto-tab-discard
        refined-github
        furiganaize
      ];
      settings = {
        # Automatically enable extensions
        "extensions.autoDisableScopes" = 0;
        # Disable extension auto update
        "extensions.update.enabled" = false;
      };
    };
  };
}
