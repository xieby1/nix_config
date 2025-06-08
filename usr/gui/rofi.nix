{ config, pkgs, stdenv, lib, ... }:
let
  my-rofi = pkgs.rofi.override {
    plugins = with pkgs; [
      # rofi-file-browser
    ];
  };
in
{
  home.packages = with pkgs; [
    my-rofi
  ];

  # gnome keyboard shortcuts
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_window/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_drun/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_wm/"
  ];
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_window" = {
    binding="<Super>w";
    command="rofi -show window";
    name="rofi window";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_drun" = {
    binding="<Super>d";
    command="rofi -show drun";
    name="rofi drun";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_wm" = let
    wm = pkgs.python3Packages.callPackage (pkgs.fetchFromGitHub {
      owner = "xieby1";
      repo = "rofi-wm";
      rev = "5d3a13d3293b2e3a06a528f03bdfa99db5d4fd7b";
      hash = "sha256-rWn4k2AD5vRv0Dz+K1aIOmG74Nilw5NZPs3xQCIS3Ew=";
    }) {};
  in {
    binding="<Super>q";
    command="rofi -show wm -modes wm:${wm}/bin/wm.py";
    name="rofi wm";
  };

  home.file.rofi_config = {
    target = ".config/rofi/config.rasi";
    text = ''
      /* This is a comment */
      /* rofi -dump-config */

      configuration {
        modes: [
          window,
          drun,
          run,
          ssh
          /* file-browser-extended */
        ];
        terminal: "kitty";
        dpi: 1;
        show-icons: true;
      }
      filebrowser {
        directory: "~/Documents";
      }

      /* man rofi-theme */

      window {
        width: 80%;
      }
    '';
  };

  # home.file.rofi_file_browser_config = let
  #   openDir = pkgs.writeScript "openDir" ''
  #     if [[ -d "$1" ]]; then
  #       xdg-open "$1"
  #     elif [[ -f "$1" ]]; then
  #       xdg-open "''${1%/*}"
  #     fi
  #   '';
  # in {
  #   target = ".config/rofi/file-browser";
  #   text = ''
  #     # This is a comment
  #     dir ~/Documents
  #     depth 0
  #     no-sort-by-type
  #     sort-by-depth

  #     # BUG: rofi -show-icons causes segmentation fault
  #     # oc-search-path
  #     # oc-cmd "nautilus"
  #     # oc-cmd "${openDir}"
  #   '';
  # };
}
