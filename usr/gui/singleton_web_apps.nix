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
     kitty nvim my_cheatsheet.mkd -c Outline
     make
  '';
in
{
  xdg.desktopEntries = {
    # singleton apps
    my_cheatsheet_md = {
      name = "Cheatsheet Edit MD";
      genericName = "cheatsheet";
      exec = "${singleton_sh} my_cheatsheet.mkd ${open_my_cheatsheet_md_sh}";
      icon = builtins.toFile "cheatsheet.svg" ''
        <svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
          <rect width="100%" height="100%" rx="20%" ry="20%" fill="#666666"/>
          <text x="50%" y="50%" text-anchor="middle" dominant-baseline="middle" font-size="18" font-weight="bold" fill="#F5F5F5">
            <tspan x="50%" dy="-1.0em">CS</tspan>
            <tspan x="50%" dy="1.0em">Edit</tspan>
            <tspan x="50%" dy="1.0em">MD</tspan>
          </text>
        </svg>
      '';
    };
  };
}
