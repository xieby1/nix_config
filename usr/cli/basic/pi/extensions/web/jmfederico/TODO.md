# jmfederico/pi-web — Nix packaging TODO

Upstream: <https://github.com/jmfederico/pi-web> · docs <https://pi-web.dev/>
Three binaries: `pi-web-sessiond` (owns session runtimes), `pi-web-server` (HTTP/WS),
`pi-web` (CLI). The daemon split is the point: **web restarts do not kill in-flight work.**

## Status

Packaging done and verified on the local host (built, ran on `127.0.0.1:8504`).
Pinned **`v1.202609.0`** — the last release whose peer range
(`>=0.84.0 <0.85.0 || >=0.85.1`) accepts our pi `0.86.1`; `v1.202609.1` needs `>=0.87.0`.

Two non-obvious fixes, both in `./default.nix`:
- `lock-integrity.patch` — upstream's lock omits `integrity` for 5 nested
  `@earendil-works/*` deps → `prefetch-npm-deps` panics.
- `npmDepsFetcherVersion = 2` — fixes `ENOTCACHED` for those nested peer tarballs.

Resolved facts:
- The server **imports** the pi SDK, so npm's in-range `0.85.1` is bundled; `pkgsu` `pi`
  (`0.86.1`) only goes on `PATH`. `--legacy-peer-deps` gives a mixed 0.85.1/0.86.1 SDK — wrong.
- `extensions/pi-web.ts` is only the pi-CLI `/web` shim; plugins build into `dist/pi-web-plugins`.
- The `@jmfederico/pi-relay` auto-install is disabled by the seeded dismissal file.

## Remaining

- [ ] Testing: persistence (restart `pi-web-web` mid-turn), resume a CLI session, our 7
      extensions load (`titlebar-spinner.ts` / `pi-heuristic-notify.ts` no-op), `ddgs` MCP via
      `pi-mcp-adapter`, and confirm yq-merge still owns `settings.json` / `models.json`.
- [ ] Server phase: Caddy `redir /pi /pi/` +
      `handle /pi/* { route { import auth; uri strip_prefix /pi; reverse_proxy 127.0.0.1:8504 } }`;
      `PI_WEB_ALLOWED_HOSTS=xieby1.cn` (add to the unit if the proxy needs it).
- [ ] Trial, then keep or remove (drop units + Caddy block + pin, `switch`, GC).

## Not taken

Dropping the bundled `dist/pi-packages` would remove the Relays plugin and let the
dismissal seed go away — take it only if Relays turns out unneeded.
