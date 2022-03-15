# Why need gsettings, given existed dconf.settings
#   tldr: dconf uses schema path, gsettings use schema id. path & id could be different.
#   https://askubuntu.com/questions/416556/shouldnt-dconf-editor-and-gsettings-access-the-same-database
# How to use gsettings?
#   example to hide gnome-terminal title bar(header bar):
#     https://askubuntu.com/questions/1370943/how-can-i-remove-the-gnome-terminal-title-bar-using-pixel-saver-in-ubuntu-21-10
{ config
, lib
, pkgs
, ...
}:
with lib;
{
  options = {
    gsettings = mkOption{
      type = with types; attrsOf (attrsOf str);
      default = {};
      example = ''
        {
          "org.gnome.Terminal.Legacy.Settings" = {
            "headerbar" = "false";
            "default-show-menubar" = "false";
          };
        }
      '';
      description = "gsettings.<path>.<key> = <value>";
    };
  };

  config = {
    # home-manager option home.activation to see dag nodes
    home.activation.gsettings = lib.hm.dag.entryAfter [ "dconfSettings" ] (
      let
        # p: path, k: key, v: value
        key_value = lib.mapAttrsToList (k: v: k+" "+v);
        # lists = [ [...] ... [...] ]
        lists = lib.mapAttrsToList (p: k_v: map (x: p+" "+x) (key_value k_v)) config.gsettings;
        # list = [...]
        list = builtins.concatLists lists;
        list_n = map (x: "${pkgs.glib}/bin/gsettings set "+x+"\n") list;
        commands = builtins.toString list_n;
      in "${commands}"
    );
  };
}
