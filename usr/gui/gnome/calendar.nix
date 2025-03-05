#MC # Gnome calendar: add caldav and enable notification
# TODO: update existing ini
{ config, pkgs, lib, ...}:
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

  genCalSource = {
    DisplayName # name displayed on calendar
  , url # caldav url, like "https://miao.wang/xxx/xxxx/xx.ics"
  , Color
  }: let
    parsedUrl = parseUrl url;
  in (pkgs.formats.ini {}).generate "${DisplayName}.source" {
    "Data Source" = {
      inherit DisplayName;
      Enabled=true;
      Parent="webcal-stub";
    };
    Authentication = {
      Host=parsedUrl.host;
      Method="plain/password";
      Port=parsedUrl.port;
      ProxyUid="system-proxy";
      RememberPassword=true;
      User="";
      CredentialName="";
      IsExternal=false;
    };
    Security = {
      Method=parsedUrl.security;
    };
    "WebDAV Backend" = {
      AvoidIfmatch=false;
      CalendarAutoSchedule=false;
      Color="";
      DisplayName="";
      EmailAddress="";
      ResourcePath=parsedUrl.path;
      ResourceQuery="";
      SslTrust="";
      Order=4294967295;
      Timeout=90;
    };
    Calendar = {
      BackendName="webcal";
      inherit Color;
      Selected=true;
      Order=0;
    };
    Offline = {
      StaySynchronized=true;
    };
    Refresh = {
      Enabled=true;
      EnabledOnMeteredNetwork=true;
      IntervalMinutes=30;
    };
    Alarms = {
      IncludeMe=true;
      # LastNotified="2025-02-24T13:27:00Z";
      LastNotified="";
      ForEveryEvent=true;
    };
  };

  caldavs = let
    path = "${config.home.homeDirectory}/Gist/Vault/caldavs.nix";
  in lib.optionals (builtins.pathExists path) import path;
in {
  dconf.settings = {
    "org/gnome/evolution-data-server/calendar" = {
      defall-reminder-enabled=true;
      notify-enable-audio=false;
      notify-enable-display=true;
      notify-past-events=true;
      notify-with-tray=true;
    };
  };

  home.activation = builtins.listToAttrs (map (args: let
    cal_source = genCalSource args;
  in {
    name = cal_source.name;
    value = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/evolution/sources/
      $DRY_RUN_CMD cp -f $VERBOSE_ARG ${cal_source} ~/.config/evolution/sources/${cal_source.name}
      $DRY_RUN_CMD chmod +w $VERBOSE_ARG ~/.config/evolution/sources/${cal_source.name}
    '';
  }) caldavs);
}
