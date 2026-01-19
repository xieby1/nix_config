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
      disabled=[
        "org.gnome.Settings.desktop"
        "org.gnome.Contacts.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.Calendar.desktop"
        "org.gnome.Characters.desktop"
        "org.gnome.clocks.desktop"
        "org.gnome.seahorse.Application.desktop"
        "org.gnome.Epiphany.desktop"
      ];
    };
    "org/gnome/shell/extensions/windows-search-provider" = {
      # fuzzy search
      search-method=1;
    };
  };
}
