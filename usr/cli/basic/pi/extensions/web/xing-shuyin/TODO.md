# xing-shuyin/pi-web-ui — Nix packaging TODO

Upstream: <https://github.com/xing-shuyin/pi-web-ui>
Single Node server; pi SDK runs **in-process**. Bundles its own pi SDK (`>=0.85.1 <0.87.0`),
which resolves to **`0.86.1` — the same as our current pi**, so it works without bumping pi.

## Version

Pin **`v0.94.1`**. Re-check the resolved SDK version and widen only together with a pi bump.

## Packaging

- [ ] npins pin in `npins/ai/pi/sources.json` → `GitRelease` `v0.94.1` (`xing-shuyin/pi-web-ui`).
- [ ] `./default.nix` — **pnpm, not `buildNpmPackage`**: `@earendil-works/pi-coding-agent`'s
      tarball embeds an `npm-shrinkwrap.json` with missing `integrity`, so npm's `fetchNpmDeps`
      panics; pnpm does not parse embedded shrinkwrap.
  - [ ] Commit `pnpm-lock.yaml` (from the upstream `package-lock.json` via `pnpm import`) and copy
        it in `postPatch`; **pass the same `postPatch` to `fetchPnpmDeps`**.
  - [ ] `fetchPnpmDeps` with `pnpm config set minimum-release-age 0` (packaged on release day).
        Drop the macOS-only `package-import-method hardlink` workaround.
  - [ ] `postPatch` writes `pnpm-workspace.yaml` with `allowBuilds` — keep only what the build
        actually errors on (start with `node-pty`, `esbuild`); drop desktop-only `electron-winstaller`.
  - [ ] `nativeBuildInputs = [ pnpm pnpmConfigHook nodejs_22 python3 ]` (`python3` for node-gyp).
  - [ ] `buildPhase`: link `node-gyp` from `.pnpm`, `pnpm rebuild --pending`, `pnpm run build`.
    - [ ] **Option to evaluate**: pin the **npm tarball** (upstream ships `dist/` only there) and
          skip `pnpm run build` entirely.
  - [ ] `installPhase`: copy to `$out/lib/node_modules/pi-web-ui/`, drop the injected `node-gyp`
        symlink, `patchShebangs` `bin/pi-web-ui.mjs`, symlink `$out/bin/pi-web-ui`.
- [ ] Home Manager — one `systemd.user.services.pi-web-ui`:
  - [ ] `ExecStart = pi-web-ui --port 8787 --host 127.0.0.1 --agent-dir ~/.pi/agent
        --data-dir ~/.pi-web --no-browser`; `WorkingDirectory = home`; `Restart=on-failure`.
- [ ] Caddy (`server/caddy/default.nix`): dedicated hostname root (e.g. `webui.xieby1.cn`) — its
      frontend requests absolute `/assets/…`, `/api/health`, `/favicon.svg` and enforces Origin≡Host
      (host **and** port). Add `import auth` + WebSocket forwarding.
- [ ] Wire the module into the extensions import list.

## Testing

- [ ] `nix build`; confirm `node-pty` compiled.
- [ ] `GET /api/health` → `engine` + `piSdkCopies` (expect the vendored `0.86.1`, not our Nix pi).
- [ ] HM service up; `journalctl --user -u pi-web-ui -f`.
- [ ] History lists `~/.pi/agent/sessions/--<cwd>--/`.
- [ ] Our 7 extensions + `ponytail` skills + `ddgs` MCP via `pi-mcp-adapter`.
- [ ] Leave its built-in `~/.pi-web/mcp.json` unused; do not double-register `ddgs`.
- [ ] Confirm yq-merge did not lose `settings.json` / `models.json`; note whether it writes a
      `provider-keys.json` into `~/.pi/agent` (a second key store beside `models.json`/`auth.json`).
- [ ] PWA on phone + tablet through Caddy + Authelia; background notifications; offline shell.
- [ ] Restart mid-turn → turn lost (in-process); record vs jmfederico.
- [ ] Trial, then keep or remove.

## Open questions

- Pin name under `npins/ai/pi/` — propose `pi-web-ui-xing-shuyin`.
- Where to wire the import: `extensions/default.nix` currently lists pi **extensions**; these are
  Home Manager services. Decide the import site.
- **npm tarball vs GitHub tag build** — decides the whole `buildPhase`; must be settled first.
- Caddy dedicated hostname needs a DNS record **and** the Authelia session cookie to cover it
  (or `PI_WEB_ALLOW_ORIGINS`); not yet planned. A subpath is the fallback we rejected.
- `nodejs_22` attribute vs upstream `engines.node >= 22.19.0`.
- pnpm version must match whoever generated `pnpm-lock.yaml` (`pnpm import` output vs `fetchPnpmDeps`).
- `~/.pi-web` may already hold files from a jmfederico default run — confirm separation.
