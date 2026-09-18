{ pkgs, ... }: {
  home.packages = [
    (pkgs.rofi.override { plugins = [ /*pkgs.rofi-file-browser*/ ]; })
    pkgs.wmctrl
  ];

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
        directory: "~/Docs";
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
  #     dir ~/Docs
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
