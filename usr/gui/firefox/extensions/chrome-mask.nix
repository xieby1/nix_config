{ pkgs, ... }: {
  programs.firefox.profiles.xieby1.extensions.packages = [(
    pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
      pname = "chrome-mask";
      version = "8.0.0";
      addonId = "chrome-mask@overengineer.dev";
      url = "https://addons.mozilla.org/firefox/downloads/file/4618461/chrome_mask-8.0.0.xpi";
      sha256 = "0w11la8sgg9pyw5zl3ki679g3353qxrd14gd0jq9m3i4fx35d250";
      meta = {
        mozPermissions = [ "storage" "tabs" "webRequest" "webRequestBlocking" "<all_urls>" ];
        platforms = pkgs.lib.platforms.all;
      };
    }
  )];
}
