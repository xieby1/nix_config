# cgit TODO

- [ ] CLI `git clone https://xieby1.cn/repos/X.git` behind Authelia will likely fail.
  `forward_auth` returns a browser/portal flow (redirect or 401), which `git` cannot
  complete. Browser browsing is unaffected.
  Options to fix: an Authelia app password/token, basic-auth support, or an
  unauthenticated clone endpoint.

- [ ] didn't test at runtime (no server access) - PATH_INFO/SCRIPT_NAME mapping is
  the bit most likely to need a tweak.
