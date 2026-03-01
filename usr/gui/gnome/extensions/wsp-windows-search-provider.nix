{ pkgs, ... }: {
  home.packages = [ pkgs.gnomeExtensions.wsp-windows-search-provider ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "windows-search-provider@G-dH.github.com"
      ];
    };
    # Disable file index
    "org/freedesktop/tracker/miner/files" = {
      index-recursive-directories=[];
      index-single-directories=[];
    };
    # Disable all gnome providers, we use only wsp-windows-search-provider
    "org/gnome/desktop/search-providers" = {
      disable-external=true;
    };
    "org/gnome/shell/extensions/windows-search-provider" = {
      # fuzzy search
      search-method=1;
    };
  };
}
