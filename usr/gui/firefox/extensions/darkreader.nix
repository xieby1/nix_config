{ pkgs, ... }: {
  programs.firefox = {
    profiles.xieby1 = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
      ];
    };
  };
  firefox-extensions.xieby1."${pkgs.nur.repos.rycee.firefox-addons.darkreader.addonId}" = {
    storage = {
      schemeVersion = 2;
      syncSettings = false;
      disabledFor = [
      ];
    };
  };
}
