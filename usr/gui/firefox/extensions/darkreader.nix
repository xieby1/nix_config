{ pkgs, ... }: let
  darkreader = pkgs.nur.repos.rycee.firefox-addons.darkreader;
in {
  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = [ darkreader ];
    };
  };
  firefox-extensions.xieby1.browser-extension-data."${darkreader.addonId}" = {
    storage = {
      schemeVersion = 2;
      syncSettings = false;
      disabledFor = [
        # markdown-preview-nvim: x.x.x.x:7768
        # markdown_revealjs daemon: x.x.x.x:7782
        "/.*:77[0-9][0-9]/"
        # markdown_revealjs
        "//home/.*/slides/index.html/"
      ];
    };
  };
}
