# xing-shuyin/pi-web-ui — Nix packaging TODO

Upstream: <https://github.com/xing-shuyin/pi-web-ui>
Single Node server; pi SDK runs **in-process**. Bundles its own pi SDK; the lockfile pins
**`0.85.1`** (same as jmfederico's — our Nix pi is `0.86.1`). `/api/health`'s `piSdkCopies`
reports that one copy, so the two do not collide.

## Status

Packaging done and verified on the local host (built, ran on `127.0.0.1:8787`). Pin **`v0.94.1`**.

Plain `buildNpmPackage` — the pre-build draft's pnpm route turned out unnecessary:
- `lock-integrity.patch` — upstream lock omits `integrity` for the nested `@earendil-works/*` peers.
- `npmDepsFetcherVersion = 2` — the v1 hash `lY7miO…` becomes `KRNKlSG…` (different cache layout).

Default install hook (no custom `installPhase`): it generates `bin/pi-web-ui` and packs the
package.json `"files"` set (`dist/`, `web/dist/`, `themes/`, `plugin-sdk/`) — closure ~727 MiB.

## Remaining

- [ ] Testing: our 7 extensions load; `ddgs` MCP via `pi-mcp-adapter`; history lists
      `~/.pi/agent/sessions/`; confirm yq-merge still owns `settings.json`/`models.json` and note
      whether a `provider-keys.json` appears beside them.
- [ ] Caddy: needs a dedicated hostname (frontend uses absolute `/assets`, `/api/health`,
      `/favicon.svg` and enforces Origin≡Host incl. port) — see `../COMPARISON.md`.
- [ ] Restart mid-turn → turn lost (in-process), vs jmfederico's daemon split.
- [ ] Confirm its data dir `~/.pi-web` does not collide with pi-web's.

## Not taken

_Dropped_: the pnpm packaging route the pre-build draft described (`pnpm import`, `fetchPnpmDeps`,
`allowBuilds`, …) — `buildNpmPackage` works once the missing `integrity` fields are patched.
