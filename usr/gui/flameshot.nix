#MC Advanced screenshot: flameshot
{ pkgs, ... }: {
  home.packages = [
    pkgs.flameshot
  ];
  dconf.settings = {
    "org/gnome/shell/keybindings" = {
      screenshot = [];
      screenshot-window = [];
      show-screen-recording-ui = [];
      show-screenshot-ui = ["<Shift>Print"];
    };
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/"
    ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot" = {
      binding="Print";
      command="${pkgs.flameshot}/bin/flameshot gui";
      name="flameshot";
    };
  };
  home.file.autostart_flameshot = {
    source = "${pkgs.flameshot}/share/applications/org.flameshot.Flameshot.desktop";
    target = ".config/autostart/org.flameshot.Flameshot.desktop";
  };
  systemd.user.tmpfiles.rules = [
    "L? %h/.config/flameshot/flameshot.ini - - - - %h/Gist/Config/flameshot.ini"
  ];
}
