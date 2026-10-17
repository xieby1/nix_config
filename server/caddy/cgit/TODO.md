# cgit TODO

- [ ] CLI `git clone https://xieby1.cn/repos/X.git` behind Authelia will likely fail.
  `forward_auth` returns a browser/portal flow (redirect or 401), which `git` cannot
  complete. Browser browsing is unaffected.
  Options to fix: an Authelia app password/token, basic-auth support, or an
  unauthenticated clone endpoint.

- [x] runtime browsing verified. PATH_INFO/SCRIPT_NAME mapping is fine.
  Note: cgit's config reader keeps spaces in the key name (`scan-path ` != `scan-path`),
  so the generated cgitrc must use `key=value` with no space around '='. With spaces,
  every option is silently ignored and cgit shows "No repositories found".
