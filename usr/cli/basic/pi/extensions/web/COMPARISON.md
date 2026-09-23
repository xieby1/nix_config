# Pi Web UI Comparison

Web/browser UIs for the pi coding agent. Evaluated for *my* setup:

- VPS = Home Manager `targets.genericLinux`, **root systemd user services + linger**
  (`server/default.nix`, `server/caddy`, `server/authelia`).
- Access = **Caddy + Authelia forward_auth** at `xieby1.cn`, **one subpath per app**
  with `uri strip_prefix` (see `/sixu/xby/*`, `/circle/xby/*`, `/web/*`).
- pi is **Nix-pinned** via `pkgs.pkgsu.pi-coding-agent`; sessions symlinked out of
  store to `~/Gist/Data/pi/sessions`. One reproducible agent runtime, please.
- Use from phone/tablet, sessions must not die when the browser goes away.

Versions/stars as of 2026-09-23. pi-coding-agent latest = `0.87.1`; **our installed pi = `0.86.1`** (pkgsu).

## At a glance

| | jmfederico/pi-web | xing-shuyin/pi-web-ui | agegr/pi-web |
|---|---|---|---|
| Stars / npm | 803★ / 8.8k mo | 230★ / 27.2k mo | 6707★ / 21.7k mo |
| Runtime | **separate session daemon** + web/API | pi SDK **in-process** | pi SDK **in-process** |
| In-flight turn survives web restart | **yes** | no | no |
| Idle eviction | no | no | **yes, 10 min default** (`PI_WEB_IDLE_TIMEOUT_MS`) |
| pi SDK binding | **peer `>=0.87.0`** (uses your pi) | bundled `>=0.85.1 <0.87.0` | bundled pinned `0.87.0` |
| Works on our pi `0.86.1` | **no — bump pi to ≥0.87.0 first** | **yes — bundled resolves to `0.86.1`, same as ours** | yes (bundles `0.87.0`, ignores ours) |
| Multi-machine fleet | **yes** | no | no |
| Built-in auth | none (proxy only) | token (`PI_WEB_TOKEN`) | password + throttle |
| Subpath / prefix deploy | **documented, relative URLs** | nginx recipe, but **absolute `/assets`** | no documented basePath |
| Mobile / PWA | PWA, mobile nav still open | **best**: PWA + SW OS notif + offline | PWA, iOS 16.2 blank page, poll battery |
| Nix packaging | `ogglord/pi-web-nix` (pkg + NixOS module) | `Sion10032/pi-web-ui-nix` (**home-manager module**) | **none** |

## pi SDK binding — the important axis

`@earendil-works/pi-coding-agent` is one package with both the `pi` CLI and the SDK.

- **jmfederico**: `peerDependencies >=0.87.0`, no bundled copy → runs **your installed
  pi**. `ogglord/pi-web-nix` exposes a `piPackage` option for a Nix-provided pi. Clean fit
  with `pkgs.pkgsu.pi-coding-agent`.
- **xing-shuyin**: bundles `>=0.85.1 <0.87.0`, which resolves to **`0.86.1` — exactly our
  installed pi**. It does *not* drift from us today; it only lags the upstream npm release
  (`0.87.1`). It will drift the moment pkgsu bumps us to `0.87.x`, until the author widens
  the range. `PI_WEB_SDK=global` / `/api/health` → `piSdkCopies` are the escape hatches.
- **Reality for us**: jmfederico's peer floor (`>=0.87.0`) is **above our pin** (`0.86.1`)
  → it cannot run until pi is bumped. xing-shuyin's bundle matches us today.
- **agegr**: bundles pinned `0.87.0` (`pi-ai`/`pi-tui`/`pi-agent-core`/`pi-coding-agent`)
  → effectively aligned with the CLI, but still a second, npm-managed copy.

Config reuse is **not** blocked by bundling — all three read `~/.pi/agent` (or
`PI_CODING_AGENT_DIR`) and share sessions. Only the *code* version differs.

## jmfederico/pi-web (PI WEB)

- Pros:
  - **Session daemon decoupled from web/API** → phone disconnects and web restarts do
    not interrupt work. The one thing that matters for an always-on VPS.
  - Runs **your pi** (peer dep); `ogglord/pi-web-nix` already splits it into
    `pi-web-sessiond` + `pi-web` services — maps onto root systemd user services.
  - **Blocker today**: requires pi `>=0.87.0`; our pin is `0.86.1`. Bump pi first.
  - **Fleet**: one gateway can proxy projects/sessions/terminals/git from other machines.
  - Subpath/prefix deploy documented (relative browser + PWA URLs) → fits
    `handle /pi/* { import auth; uri strip_prefix /pi; reverse_proxy 127.0.0.1:8504 }`.
  - Authelia covers its missing built-in auth.
- Cons:
  - **No built-in auth at all** (README/FAQ: do not expose to the internet; VPN/tunnel/
    authenticated proxy only).
  - **English-only**; no PDF/DOCX/audio preview (#119); no ANSI tool output (#121); no
    chat minimap (#118); no per-message rewind/fork (#237, #221); no web push (#193).
  - Session views go blank after a session-daemon restart, no replay (#185).
  - Mobile nav redesign pending (#173); younger project (803★).
  - `ogglord/pi-web-nix` is brand-new/0-star → vendor it, don't trust it blindly.

## xing-shuyin/pi-web-ui

- Pros:
  - **Best browser/mobile client**: installable PWA, service-worker OS notifications that
    fire while backgrounded, offline shell, 10 languages, desktop app.
  - Richest features: subagents + templates, MCP hot-reload, terminal-backed bash, Git
    panel, background-task panel, goal mode, plugins/themes, DSH engine.
  - Built-in token auth + strict Origin/Host check + host allow-list (defense in depth).
  - **Best Nix story**: `Sion10032/pi-web-ui-nix` ships a **home-manager module** + VM test.
  - Very active (daily releases).
- Cons:
  - **Bundled npm SDK** (`0.86.1`) — matches our pi *today*, but is a second copy we do
    not control; drifts when pkgsu bumps pi (see above).
  - **In-process runtime**: a server restart loses the in-flight turn (it only reports
    "last run was interrupted" afterward).
  - Subpath hosting fights the **absolute `/assets/`, `/api/health`, `/favicon.svg`**
    requests + strict Origin≡Host (hostname **and** port) → needs extra Caddy blocks and
    likely `PI_WEB_ALLOW_ORIGINS`.
  - Newest (2026-08); one merge/release owner (code contributions are multi-person).
    Its **0 open issues is a triage artifact**, not stability: 137 filed in 7 weeks, median
    4.1 h to close (see Stability).
  - node-pty native module → build script must be allowed in the derivation.

## agegr/pi-web

- Pros:
  - Biggest project (6707★) and most polished *local* client: session branching, file
    preview (PDF/DOCX/audio), minimap, ANSI, Mermaid, provider usage, i18n, built-in
    password + throttle.
  - Reads the same config/session files as pi ("shared configuration").
- Cons:
  - **Local-first design**, not a remote control plane.
  - **No documented basePath** → awkward under the shared-host subpath Caddy pattern.
  - **Idle session eviction** (10 min) + no daemon separation.
  - **Memory never returned to the OS** — #923 (one forced GC freed 360 MB / 40% RSS at
    14 h uptime; 48 h run degraded). Bad for a 24/7 root service.
  - Bundles its own pinned SDK; **no Nix packaging exists**.
  - iOS 16.2 blank page (#753); mobile battery/heat (#924).

## Reuse of `~/.pi/agent`

Both finalists default `--agent-dir` / `PI_CODING_AGENT_DIR` to `~/.pi/agent`, so both read
our settings, models, auth, extensions, skills, sessions, packages, and MCP — but it is not
pure reuse:

| `~/.pi/agent/*` | jmfederico | xing-shuyin |
|---|---|---|
| `settings.json` | ✅ agent state | ✅ read + its own Settings UI |
| `models.json`, `auth.json` | ✅ | ✅ |
| `extensions/` (our 7) | ✅ "globally installed Pi extensions" | ✅ per-extension switches |
| skills | ✅ | ✅ |
| `sessions/` | ✅ | ✅ `<agentDir>/sessions/--<cwd>--/` |
| `npm/` pi packages | ✅ | ✅ reads `<agentDir>/npm/package.json` |
| `trust.json` | ✅ explicit; no browser trust prompt | reads agent dir; undocumented |
| `mcp.json` (`ddgs`) | via our `pi-mcp-adapter` | via our extension **+ its own `~/.pi-web/mcp.json`** |
| injects own pi extension | ✅ `extensions/pi-web.ts` + packages | ✅ `extensions/webui.ts` |
| own UI state dir | `~/.config/pi-web/` | `~/.pi-web/` |

Caveats:
- **Version gate** (above) decides whether either even runs on our pin.
- **Both inject their own extension** → ours *plus* theirs, not pure reuse.
- **xing-shuyin adds a second MCP surface** (`~/.pi-web/mcp.json`) beside our extension.
- **Declarative conflict**: our `settings.json`/`models.json` are yq-merge-managed and our
  `extensions/` are read-only store symlinks; both UIs' Settings panels write those files,
  so treat them read-only or fold changes back into yq-merge. xing-shuyin also writes
  `provider-keys.json` into the agent dir.
- **TUI-only extensions** (`titlebar-spinner.ts`, `pi-heuristic-notify.ts`) likely no-op or
  warn under a headless web runtime.
- **npm update flows** (`pi install`, `npm i -g`) do not fit our Nix model — disable them.

## Stability

| | xing-shuyin | jmfederico |
|---|---|---|
| Age | 7 weeks | 4.5 months |
| Issues filed / open | 137 / **0** | 104 / **38** (~5 bugs, rest features) |
| Median time-to-close | **4.1 h** | 67.8 h |
| Closed ≤24 h | **93%** | 33% |
| p90 time-to-close | 19 h | **≈37 days** |
| Commits, last 30 d | **653** | 191 |
| Releases, last 30 d | **57 (~2/day)** | 3 (monthly) |
| Bug reports / month | **~19** | ~2.7 |

xing-shuyin is **responsive but volatile** — a rolling release at ~7× the bug-discovery rate;
its 0-open board is a triage artifact (median 4.1 h), not an absence of defects (the closed
set includes data loss #280 and a compaction desync #276). jmfederico is **conservative but
slow** — monthly releases and fewer bugs, but a 37-day p90 lets real bugs (#185) linger. For
a 24/7 box we leave alone, lower churn wins.

## Verdict

**`jmfederico/pi-web`** for this box — *once pi is bumped to `>=0.87.0`*:

1. Only one that runs **our Nix-pinned pi** (peer dep + `piPackage`), no second runtime.
2. Only one whose architecture matches "VPS + phone/tablet" (daemon; survives web restart).
3. Fits the existing Caddy subpath + Authelia forward_auth pattern (relative URLs).
4. Authelia neutralises its one real weakness (no auth).
5. Low churn / monthly releases — the more stable base (see Stability).

**Today it does not run**: our pin is `0.86.1`, jmfederico needs `>=0.87.0` — bump pi in
pkgsu/npins and re-verify extensions/patches before adopting.

**Switch to `xing-shuyin/pi-web-ui`** only if the client experience (mobile PWA,
notifications, subagents/MCP/git/goal mode) outweighs: bundled npm SDK instead of
`pkgsu` pi, in-process runtime (restart kills the turn), subpath friction.

**Not `agegr/pi-web`** for the server — local-first, no basePath, idle eviction + memory
leak, no Nix packaging. Keep it as a *local desktop* companion.

## Integration sketch (jmfederico)

- **First bump pi to `>=0.87.0`** (pkgsu/npins) and re-verify extensions/patches.
- Package `@jmfederico/pi-web` via `buildNpmPackage` (allow node-pty build script), or
  vendor `ogglord/pi-web-nix`; pin with npins like sixu.
- Two `systemd.user.services`: `pi-web-sessiond` and `pi-web`, bind `127.0.0.1:8504`,
  `piPackage = pkgs.pkgsu.pi-coding-agent`, `PI_WEB_ALLOWED_HOSTS=xieby1.cn`.
- Caddy: `redir /pi /pi/` + `handle /pi/* { route { import auth; uri strip_prefix /pi;
  reverse_proxy 127.0.0.1:8504 } }` (WebSocket included).
- Skip `pi-web install` — define the units declaratively.

## Also considered

- `ygncode/pi-web` — Go server, PWA-first, Tailscale-native, mobile-optimised; beta,
  thinner adoption (711 mo). Best if mobile UX > maturity.
- `thecodacus/pithagoras` — server-owned runs, append-only event log replays missed
  events, built-in `PORTAL_PASSWORD`, channels (Discord/Telegram); Docker. Pick if you
  want built-in auth without a VPN.
- `rcarmo/piclaw` — self-hosted "AI workspace", Docker/portable, scheduled tasks, i18n.
- `BlackBeltTechnology/pi-agent-dashboard` — "army of agents": parallel sessions,
  OpenSpec, zrok tunnel.
- `Epsilondelta-ai/pi-web` — single Go binary + trusted plugin catalog.
- `isr4el-silv4/pi-web-ui` — *not* a session UI: Chrome side-panel + CDP bridge to give
  the agent browser control.
- Forks/derivatives of agegr: `@pricening/pi-web`, `@silgrid/pi-web`, `@rainmanhhh/pi-web`,
  `@baique/pi-web-sky`, `@realchendahuang/dahuang-pi-web-ui`, `@twofive/snail-pi-web`,
  `@timmygod/pi-web-local` (= ygncode fork tuned for local LLMs).
- Shared gaps of all: no multi-user/RBAC, no sandbox (agent has the VPS shell), no
  native mobile app, no GitHub/PR integration, no cron/scheduled runs.
