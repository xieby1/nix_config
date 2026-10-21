# Pi skill-usage trackers

Decision record for "which of my skills are dead weight?" — the question that prompted
this comparison. Written 2026-10-21 against `pi-coding-agent` 1.2.0.

## Requirements

- **R1 — answers the question.** Reports the skills that have *not* fired, not just the
  ones that have. Reading a list of used skills and subtracting my own installed set by
  hand is the thing I wanted to stop doing.
- **R2 — global.** One answer across projects. "Unused in this repo" is a weaker question
  than "unused everywhere", and most of my skills are global (`pi-hermes-memory/skills`).
- **R3 — bounded storage.** Usage counters must not grow without limit, or must come with
  a retention mechanism. A log that only `rm` can shrink is a liability.
- **R4 — maintained.** Reasonable release cadence and some evidence that someone else
  uses it, or code small enough to audit in one sitting.

Trust boundary for all of them: skills are only credited when the model `read`s the
`SKILL.md`, or when I run `/skill:<name>`. Driving a skill's own `scripts/` through `bash`
is invisible to every tracker here, including any I write myself.

## Comparison

| package | version / last release | R1 unused | R2 global | R3 bounded | R4 maintained | verdict |
|---|---|---|---|---|---|---|
| `pi-tool-stats` | 1.1.1, 2026-05-31 | yes | yes | no — 2 records per tool call, ~43 MB/year, `rm` only | no — 3 versions, no repo link, single author | rejected: storage + abandonment |
| `@pify/skills` | 0.4.0, 2026-09-17 | yes | **no** — per-project ledger | yes — aggregate, flat | weak — 0 stars, but active | rejected: project-keyed only |
| `@narumitw/pi-analytics` | 0.49.11, 2026-09-20 | **no** — lists used skills only | yes | weak — JSONL generations, no retention setting | yes — 721-star repo, 14 releases | best of the packages, still fails R1 |
| `@signalridge/pi-analytics` | 1.4.0, 2026-10-18 | no — same design as narumitw | yes | weak — same | weak — 4 stars, marked experimental | rejected: clone with less traction |
| `pi-local-stats` | 0.0.4, 2026-09-09 | no — skills are one dashboard tab | yes | yes — SQLite index, rebuildable | weak — 1 star | rejected: no unused view |
| `pi-tokenburn` | 0.5.8, 2026-10-15 | no — tokens/cost only | yes | yes — per-file cache over sessions | yes — active CI | rejected: wrong metric |
| `@hank-warren/pi-stats` | 0.5.0, 2026-09-28 | no — Overview/Models/Tools/Projects | yes | yes — session-derived | weak — 1 star | rejected: no skills view |

Star counts for the whole niche, as context for how much R4 can actually be satisfied:
the ceiling for a *dedicated* tracker is 721 stars, and that is a monorepo where analytics
is one of ~30 packages. Every high-star repo in the ecosystem (`can1357/oh-my-pi` 36k,
`vercel-labs/skills` 36k installer, `backnotprop/plannotator` 9.6k, `nicobailon/pi-subagents`
4k) is a different tool, not a skill-usage tracker. Picking by stars is not available here.

## Details worth keeping

### pi-tool-stats

Storage is `~/.pi/agent/tool-stats.jsonl`, one line per event, `appendFileSync`, path
hardcoded, no rotation, no retention, no reset command. Measured on this machine: 243
sessions over 34 days = 9150 tool calls = ~270/day; two ~220-byte records per call =
~118 KB/day = **~43 MB/year**. Every `/tool-stats` reads and parses the entire file.

Its unused report is genuinely good: `PROMPT-VISIBLE UNUSED SKILLS` with approximate
prompt tokens, plus an `EXPLICIT-ONLY UNUSED SKILLS` section, and its "what exists" set
comes from `pi.getCommands()` — the correct source. That is why it was installed first.

### @pify/skills

Ledger is `~/.pi/agent/pify-skills/<sha256(lowercased cwd)[0:12]>.json`, one aggregate
entry per skill (`count`, `lastAt`, `byModel`, `byCommand`). Flat forever — the right data
model. `commitLedger` re-reads and *sums* before an atomic temp+rename, so concurrent pi
windows do not clobber each other.

Two disqualifiers:

1. **Project-keyed by design.** `resolveLedger` hashes `cwd`; `/skills` only ever reads the
   current project's file. No global route. A skill used in another repo shows as unused.
2. **Cold-start gap.** Before the first request, the authoritative set is unavailable, so it
   falls back to `loadSkills({ skillPaths: [], includeDefaults: true })`, which scans only
   `~/.pi/agent/skills` and `<cwd>/.pi/skills` — neither exists on this machine. A fresh pi
   instance answers `/skills unused` with `No skills loaded.` until one prompt has settled.

Skill costs, though, are *measured*: `formatSkillsForPrompt([])` vs
`formatSkillsForPrompt([skill])`, the same function that builds the real prompt block.

### Why `pi.getCommands()` is the right source

`pi-coding-agent` builds it at startup from the fully resolved skill set
(`dist/core/agent-session.js`, `_bindExtensionCore`):

```js
const skills = this._resourceLoader.getSkills().skills.map((skill) => ({
    name: `skill:${skill.name}`,
    source: "skill",
    sourceInfo: skill.sourceInfo,
}));
```

Extension-contributed paths (`pi-hermes-memory/skills`, `projects-memory/<project>/skills`),
`.agents/skills` and package skills are all included, and it is available before any
request. `event.systemPromptOptions.skills` on `before_agent_start` carries the same set
later. Any tracker that re-scans the disk instead will be wrong about this machine.

## Verdict

No package satisfies R1–R4 simultaneously, so the plan is a small local extension
(`pi-skill-usage`, developed in `~/Codes/MyRepos/pi-skill-usage`):

- installed set from `before_agent_start`'s `systemPromptOptions.skills`, with
  `pi.getCommands()` as the cold-start fallback (it lists only command-registered
  skills, so it is marked partial rather than reported as the whole set)
- counting from `tool_call` (a `read` of a known `SKILL.md`) and `input` (`/skill:`)
- one **global** `~/.pi/agent/skill-usage.json`, aggregate counts per skill name
- `/skill-usage unused` sorted by measured prompt-token cost
- atomic temp+rename write, re-read and sum before writing

About 180 lines of extension plus 90 of tests, no dependencies, nothing to rebase.
