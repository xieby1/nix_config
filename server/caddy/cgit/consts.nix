# Shared by the cgit Caddy route fragment (./caddy.nix) and the fcgiwrap
# service (./config.nix), which are generated from separate files but must
# agree. Keeping the port here stops the FastCGI upstream and the fcgiwrap
# listener from drifting apart.
{
  # Loopback port Caddy's fastcgi transport dials; fcgiwrap listens here.
  fcgiwrapPort = 9007;

  # URL prefix Caddy serves and strips before handing the request to cgit.
  # Capitalised to match ~/Repos; it ends up in Authelia regexes verbatim (they
  # are case-sensitive), so change it here only.
  prefix = "/Repos";

  # cgit's page cache lives at $XDG_CACHE_HOME/<cacheDir>.
  cacheDir = "cgit";
}
