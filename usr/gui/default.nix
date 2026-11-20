{ pkgs, ... }: {
  imports = [
    ./mime.nix
    ./kdeconnect.nix
    ./xdot.nix
    ./firefox
    ./warpd.nix
    ./rustdesk.nix
    ./terminal
    ./fonts.nix
    ./cheatsheet_edit.nix
    ./xcolor.nix
    ./drawio.nix
    ./flameshot.nix
    ./fcitx5
    ./de
    ./low-battery-notify.nix
    ./xingyao-audio
    ./dingtalk
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
    };
  };

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "o" ''nohup xdg-open "$@" &> /dev/null &'')
    libnotify
    # browser
    # dont ask me for keyring chromium-like browsers!
    (chromium.override {commandLineArgs="--password-store=basic";})
  ] ++ [
    # network
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    feishu
    wechat
    wemeet
    (pkgs.makeDesktopItem {
      name = "WemeetApp-XWayland";
      desktopName = "WemeetApp-XWayland";
      exec = "wemeet-xwayland %u";
      icon = "wemeet";
      type = "Application";
      terminal = false;
      categories = ["AudioVideo"];
      mimeTypes = ["x-scheme-handler/wemeet"];
    })
  ] ++ [
    # text
    #wpsoffice
    libreoffice
    # pi-attachments reads copied files via wl-paste on Wayland
    wl-clipboard
    # draw
    #aseprite-unfree
    inkscape
    gimp
    # viewer
    evince
    gnome-characters
    nautilus
    loupe
    gnome-calculator
    surfer
  ] ++ [
    vlc
    obsidian
  ] ++ [
    keepassxc
    # entertainment
    antimicrox
  ];
}
