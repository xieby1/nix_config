#MC # KDE Connect
{ pkgs, ... }: {
  home.packages = [
    pkgs.kdePackages.kdeconnect-kde
  ];
  #MC Auto startup KDE Connect after Gnome GUI login.
  home.file.kde_connect_indicator = {
    source = "${pkgs.kdePackages.kdeconnect-kde}/share/applications/org.kde.kdeconnect.nonplasma.desktop";
    target = ".config/autostart/org.kde.kdeconnect.nonplasma.desktop";
  };
}
