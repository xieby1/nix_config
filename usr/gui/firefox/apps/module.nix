#MC # firefox module
{ config, pkgs, lib, ... }: let
  singleton = pkgs.writeShellScript "singleton.sh" ''
    if [[ $# -lt 2 || $1 == "-h" ]]
    then
      echo "Usage: ''${0##*/} <wmclass> <command and its args>"
      echo "  Only start a app once, if the app is running"
      echo "  then bring it to foreground"
      exit 0
    fi

    WID=$(${pkgs.xdotool}/bin/xdotool search --class "$1")
    if [[ -z $WID ]]; then
      eval "''${@:2}"
    else
      for WIN in $WID; do
        CURDESK=$(${pkgs.xdotool}/bin/xdotool get_desktop)
        ${pkgs.xdotool}/bin/xdotool set_desktop_for_window $WIN $CURDESK
        ${pkgs.xdotool}/bin/xdotool windowactivate $WIN
      done
    fi
  '';
in {
  options = {
    firefox-apps = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = null;
          };
          url = lib.mkOption {
            type = lib.types.str;
            default = null;
          };
          desktopEntryExtras = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "extra settings for desktopEntry, see xdg.desktopEntries.<xxx>";
          };
          keybinding = lib.mkOption {
            default = null;
          };
        };
      });
    };
  };

  config = {
    programs.firefox.profiles = builtins.listToAttrs (
      lib.imap1 (i: firefox-app: {
        name = assert firefox-app.name!=null; firefox-app.name;
        value = {
          id = i;
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            # auto open all windows in fullscreen mode
            i-auto-fullscreen
            darkreader
            vimium
            ublock-origin
          ];
          settings = {
            # https://superuser.com/questions/1483037/making-firefox-fullscreen-like-without-actually-maximizing-the-window
            # the full screen hotkey/button will trigger fullscreen like normal, except it won't resize the window.
            "full-screen-api.ignore-widgets" = true;
            # Automatically enable extensions
            "extensions.autoDisableScopes" = 0;
            # https://stackoverflow.com/questions/51081754/cross-origin-request-blocked-when-loading-local-file
            "security.fileuri.strict_origin_policy" = false;
            # enable userChrome.css
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            # disable extensions auto update
            "extensions.update.enabled" = false;
          };
          userChrome = ''
            /* [Disabling the mouseover to reveal the address/toolbar while in fullscreen - old method doesn't work](https://support.mozilla.org/en-US/questions/1324666) */
            /* [prevent firefox from showing the address bar in fullscreen mode](https://support.mozilla.org/en-US/questions/1323320) */
            *|div#fullscr-toggler {display:none!important;}
          '';
        };
      }) config.firefox-apps
    );

    xdg.desktopEntries = builtins.listToAttrs (
      map (firefox-app: {
        name = assert firefox-app.name!=null; firefox-app.name;
        value = {
          name = firefox-app.name;
          genericName = firefox-app.name;
          exec = assert firefox-app.url!=null;
            "firefox -P ${firefox-app.name} --class ${firefox-app.name} ${firefox-app.url}";
          icon = builtins.fetchurl {
            url = "http://www.google.com/s2/favicons?domain=${firefox-app.url}&sz=128";
            name = "${firefox-app.name}.png";
          };
          settings = {
            StartupWMClass = firefox-app.name;
          };
        } // firefox-app.desktopEntryExtras;
      }) config.firefox-apps
    );

    dconf.settings = let
      firefox-apps-with-keybinding = (builtins.filter (firefox-app: firefox-app.keybinding!=null ) config.firefox-apps);
    in {
      "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = map (
        firefox-app: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${firefox-app.name}/"
      ) firefox-apps-with-keybinding;
    } // (builtins.listToAttrs (
      map (firefox-app: {
        name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${firefox-app.name}";
        value = {
          binding = firefox-app.keybinding;
          command = "${singleton} ${firefox-app.name} gtk-launch ${firefox-app.name}.desktop";
          name = firefox-app.name;
        };
      }) firefox-apps-with-keybinding
    ));
  };
}
