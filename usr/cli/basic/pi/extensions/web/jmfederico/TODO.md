# jmfederico/pi-web — Nix packaging TODO

Upstream: <https://github.com/jmfederico/pi-web> · docs <https://pi-web.dev/>
Three binaries: `pi-web-sessiond` (owns session runtimes), `pi-web-server` (HTTP/WS),
`pi-web` (CLI). The daemon split is the point: **web restarts do not kill in-flight work.**

## Version

Pin **`v1.202609.0`** — the last release whose peer range (`>=0.84.0 <0.85.0 || >=0.85.1`)
still accepts our pi `0.86.1`. `v1.202609.1` moved to `>=0.87.0`; do not bump until pi is
bumped in pkgsu/npins.

## Packaging

- [ ] npins pin in `npins/ai/pi/sources.json` → `GitRelease` `v1.202609.0` (`jmfederico/pi-web`).
- [ ] `./default.nix` — `buildNpmPackage` (source has `package-lock.json`):
  - [ ] `npmFlags = [ "--legacy-peer-deps" ]` — **critical**: do not vendor the
        `@earendil-works/*` peers; pi must come from `PATH` (`pkgs.pkgsu.pi-coding-agent`).
  - [ ] `npmDepsHash`; `nativeBuildInputs = [ makeWrapper ]`; `buildPhase = "npm run build"`.
  - [ ] Wrap the 3 bins from `dist/`; copy `dist` + `node_modules`; drop dangling workspace symlinks.
- [ ] Home Manager — **two** `systemd.user.services` (mirror `ogglord/pi-web-nix`):
  - [ ] `pi-web-sessiond`: `PATH` includes `pkgs.pkgsu.pi-coding-agent`;
        `PI_WEB_DATA_DIR=~/.local/state/pi-web` (**not `~/.pi-web`** — that is xing-shuyin's
        default and jmfederico's too; two daemons cannot share one data dir).
  - [ ] `pi-web-web`: `PI_WEB_PORT=8504`, `after/requires = pi-web-sessiond`.
  - [ ] No hard `ProtectHome`/`ProtectSystem` — sessions need `~/.pi/agent`, git, ssh.
- [ ] Caddy (`server/caddy/default.nix`): `redir /pi /pi/` +
      `handle /pi/* { route { import auth; uri strip_prefix /pi; reverse_proxy 127.0.0.1:8504 } }`
      (WebSocket included). `PI_WEB_ALLOWED_HOSTS=xieby1.cn`.
- [ ] Wire the module into the extensions import list.

## Testing

- [ ] `nix build`; `pi-web doctor`.
- [ ] Foreground on `127.0.0.1:8504`; `GET /api/health`.
- [ ] HM service up: `systemctl --user status pi-web-sessiond pi-web-web`; `pi-web status` / `pi-web logs`.
- [ ] **Persistence (the deciding feature)**: start a turn, restart `pi-web-web`, confirm it keeps
      running and reconnects; then restart the host and note the loss.
- [ ] Resume an existing `~/.pi/agent/sessions` transcript.
- [ ] Our 7 extensions load; `pi-heuristic-notify.ts` / `titlebar-spinner.ts` no-op, don't break startup.
- [ ] `ddgs` MCP via our `pi-mcp-adapter` reaches the agent.
- [ ] Confirm yq-merge did not lose `settings.json` / `models.json` to the UI's Settings panel.
- [ ] Caddy + Authelia: `/pi/` on desktop, then phone + tablet.
- [ ] Trial, then keep or remove (drop units + Caddy block + pin, `switch`, GC).

## Open questions

- Pin name under `npins/ai/pi/` — propose `pi-web-jmfederico`.
- Where to wire the import: `extensions/default.nix` currently lists pi **extensions**; these are
  Home Manager services. Decide the import site.
- **Does the runtime resolve pi from `PATH`, or `import` the SDK from `node_modules`?** With
  `--legacy-peer-deps` the SDK is absent from `node_modules`, so this must be verified early —
  it decides whether the whole "use our Nix pi" premise holds.
- Does `extensions/pi-web.ts` need to be copied into `$out`? The npm `files` list includes it, but
  the reference `ogglord` installPhase does not copy `extensions/`.
- `plugins/` may not exist at this tag (the reference guards with `if [ -d plugins ]`).
- `~/.local/state/pi-web`: create via systemd `StateDirectory` or `home.file`?
