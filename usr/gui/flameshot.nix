#MC Advanced screenshot: flameshot
{ pkgs, ... }: {
  home.packages = [
    pkgs.flameshot
  ];
  home.file.autostart_flameshot = {
    source = "${pkgs.flameshot}/share/applications/org.flameshot.Flameshot.desktop";
    target = ".config/autostart/org.flameshot.Flameshot.desktop";
  };
  systemd.user.tmpfiles.rules = [
    "L? %h/.config/flameshot/flameshot.ini - - - - %h/Gist/Config/flameshot.ini"
  ];
}
