#MC # gnome-calendar module
{ config, pkgs, lib, ... }: {
  options = {
    gnome-calendar = lib.mkOption {
      # entry type
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          url = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          settings = lib.mkOption {
            type = lib.types.attrs;
            default = {};
          };
        };
      });
      default = {};
      description = ''
        Attrs of calendars settings.

        gnome-calendar = {
          calendar1 = {
            url = "...calendar1.ics";
            settings = {...calendar1 settings...}
          };
          calendar2 = {
            url = "...calendar2.ics";
            settings = {...calendar2 settings...}
          };
          ...
        };
      '';
    };
  };

  config = {
    # Available options: <evolution-data-server>/data/org.gnome.evolution-data-server.calendar.gschema.xml.in
    dconf.settings."org/gnome/evolution-data-server/calendar" = {
      # Currently, cannot use audio, otherwise no notification pops out.
      # * https://gitlab.gnome.org/GNOME/gnome-calendar/-/issues/1226
      #   * https://gitlab.gnome.org/GNOME/gnome-calendar/-/issues/1280
      notify-enable-audio = false;
      notify-enable-display = true;

      # Default reminder for all events in chosen calendars
      defall-reminder-enabled = true;
      # defall-reminder-interval = 15
      # defall-reminder-units = minutes
    };
    home.activation = lib.mapAttrs (name: entry:
      let
        parseUrl = urlString:
        let
          protocolSplit = lib.strings.splitString "://" urlString;
          protocol = builtins.head protocolSplit;
          afterProtocol = builtins.elemAt protocolSplit 1;
          hostPathSplit = lib.strings.splitString "/" afterProtocol;
          host = builtins.head hostPathSplit;
          path = "/" + lib.strings.concatStringsSep "/" (builtins.tail hostPathSplit);
        in {
          inherit protocol host path;
          port = if protocol == "http" then 80
            else if protocol == "https" then 443
            else throw "unknown protocol: ${protocol}";
          security = if protocol == "https" then "tls"
            else "";
        };
        parsedUrl = parseUrl entry.url;
        mergeCfg = lib.foldl lib.recursiveUpdate {};
        cal_cfg = mergeCfg [
          (import ./template.nix)
          {
            "Data Source" = {
              DisplayName = name;
            };
            Authentication = {
              Host=parsedUrl.host;
              Port=parsedUrl.port;
            };
            Security = {
              Method=parsedUrl.security;
            };
            "WebDAV Backend" = {
              ResourcePath=parsedUrl.path;
            };
          }
          entry.settings
        ];
        src = (pkgs.formats.ini {}).generate "${name}.source" cal_cfg;
        dst = "${config.home.homeDirectory}/.config/evolution/sources/${name}.source";
      in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $(dirname ${dst})
        $DRY_RUN_CMD sed 's/LastNotified=.*/LastNotified='$(date -u +"%Y-%m-%dT%H:%M:%SZ")'/g' ${src} > ${dst}
      ''
    ) config.gnome-calendar;
  };
}
