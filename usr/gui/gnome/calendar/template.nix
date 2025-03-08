{
  "Data Source" = {
    DisplayName = builtins.trace ''gnome-calendar: it is recommended to set "Data Source".DisplayName'' "miao";
    Enabled=true;
    Parent="webcal-stub";
  };
  Authentication = {
    Host=builtins.trace ''Authentication.Host needs to be set, e.g. "outlook.live.com"'' "";
    Method="plain/password";
    Port=443;
    ProxyUid="system-proxy";
    RememberPassword=true;
    User="";
    CredentialName="";
    IsExternal=false;
  };
  Security = {
    Method="tls";
  };
  "WebDAV Backend" = {
    AvoidIfmatch=false;
    CalendarAutoSchedule=false;
    Color="";
    DisplayName="";
    EmailAddress="";
    ResourcePath=builtins.trace ''"WebDAV Backend".ResourcePath needs to be set, e.g. "/owa/calendar/xxxx/xxxx/xxxx/calendar.ics"'' "";
    ResourceQuery="";
    SslTrust="";
    Order=4294967295;
    Timeout=90;
  };
  Calendar = {
    BackendName="webcal";
    Color = "#B85450";
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
}
