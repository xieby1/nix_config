{ config, pkgs, ... }:
# TODO: change it into a module
# TODO: split
let
  singleton = pkgs.writeShellScriptBin "singleton.sh" ''
    if [[ $# -lt 2 || $1 == "-h" ]]
    then
      echo "Usage: ''${0##*/} <window> <command and its args>"
      echo "  Only start a app once, if the app is running"
      echo "  then bring it to foreground"
      exit 0
    fi

    if [[ "$1" == "kdeconnect.app" ]]
    then
      WID=$(${pkgs.xdotool}/bin/xdotool search --classname "$1")
    else
      WID=$(${pkgs.xdotool}/bin/xdotool search --onlyvisible --name "$1")
    fi

    if [[ -z $WID ]]
    then
      eval "''${@:2}"
    else
      for WIN in $WID
      do
        CURDESK=$(${pkgs.xdotool}/bin/xdotool get_desktop)
        ${pkgs.xdotool}/bin/xdotool set_desktop_for_window $WIN $CURDESK
        ${pkgs.xdotool}/bin/xdotool windowactivate $WIN
      done
    fi
  '';
  singleton_sh = "${singleton}/bin/singleton.sh";

  open_my_cheatsheet_md_sh = pkgs.writeShellScript "open_my_cheatsheet_md" ''
     cd ${config.home.homeDirectory}/Documents/Tech
     kitty nvim my_cheatsheet.mkd -c Vista
     make
  '';
in
{
  # gnome keyboard shortcuts
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my_cheatsheet_md/"
  ];
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my_cheatsheet_md" = {
    binding="<Alt>c";
    command="gtk-launch my_cheatsheet_md.desktop";
    name="edit cheatsheet";
  };

  xdg.desktopEntries = {
    # singleton apps
    my_cheatsheet_md = {
      name = "Cheatsheet MD";
      genericName = "cheatsheet";
      exec = "${singleton_sh} my_cheatsheet.mkd ${open_my_cheatsheet_md_sh}";
    };
  };
}
