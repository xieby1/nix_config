{ pkgs, ... }: {
  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
      ];
    };
  };
  firefox-extensions.xieby1.browser-extension-data."${pkgs.nur.repos.rycee.firefox-addons.darkreader.addonId}" = {
    storage = {
      schemeVersion = 2;
      syncSettings = false;
      disabledFor = [
      ];
    };
  };
}
