{ pkgs, ... }: {
  imports = [
    ./module.nix

    ./sidebery.nix
    ./darkreader.nix
    ./smartproxy.nix
    ./smart-toc.nix
    ./brotab.nix
  ];

  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        # 😾😾😾 Chinese users cannot use ad block extensions
        # https://discourse.mozilla.org/t/chinese-users-cant-use-ad-blocker-extensions/94823
        ublock-origin
        vimium
        auto-tab-discard
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
