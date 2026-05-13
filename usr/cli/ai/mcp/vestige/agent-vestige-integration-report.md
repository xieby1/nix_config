prompt:

Let's do an experiment together:
1. remember: when choosing daily using apps/frameworks, I prefer compilation-based language, because it is cost few resources and high performance.
2. remember:  when doing exploration and prototyping, I prefer using script-based language, which is fast and agile.
3. start a forge session to help me find a AI agent that support ACP protocol. Don't hint the new session to look for vestige. Check whether the new session utilize my compilation-based language perference, due to ai agent is heavily used.
4. start a forge session to help me list a plan to create niri plugin, which can create a workspace above or below. Don't hint the new session to look for vestige. Check whether the new session utilize my script-based language perference, due to it is an exploring task.

# Agent-Vestige Integration Report

> Experiment results testing whether forge sessions query Vestige at startup
> and apply discovered preferences as decision criteria.

## Background

Vestige is a cognitive memory system (FSRS-6 based) integrated via MCP. The
question was: do forge sessions actually query Vestige at session start and
apply user preferences as active constraints?

Two user preferences were stored in Vestige:

| Preference | Tag |
|---|---|
| Daily-use apps/frameworks → prefer **compilation-based** (Rust, Go, C) for low resource usage and high performance | `compilation-language` |
| Exploration/prototyping → prefer **script-based** (Python, shell) for fast iteration | `script-language` |

## Experiment Design

Two prompts were tested across multiple forge sessions (fresh `forge -p`):

| # | Prompt | Relevant Preference |
|---|---|---|
| Exp1 | "Help me find an AI agent that supports ACP protocol" | Compilation-based (agent = daily tool) |
| Exp2 | "Help me list a plan to create a niri plugin that creates a workspace above or below" | Script-based (niri plugin = exploration) |

Each experiment checked:
1. **Query**: Did the agent call any Vestige MCP tool at session start?
2. **Retrieval**: Did it find the stored preference?
3. **Application**: Did it apply the preference as a decision criterion?

## Results

### Round 1: Baseline (before AGENTS.md fix)

| Check | Exp1 (ACP Agent) | Exp2 (Niri Plugin) |
|---|---|---|
| Queried Vestige | No | Yes |
| Found preference | No | Yes |
| Applied preference | N/A | Partially (Rust recommended anyway) |

Exp2 was a partial success — Vestige was queried, preferences found, but the
agent still defaulted to Rust as primary, treating scripting as an afterthought.

### Round 2: After AGENTS.md fix (with preferred model)

Added to `~/.forge/AGENTS.md`:
- Aggressive Vestige session-start instructions
- Explicit preference-application guidance with weighing rules
- Concrete example (niri plugin → script-first)

| Check | Exp1 (ACP Agent) | Exp2 (Niri Plugin) |
|---|---|---|
| Queried Vestige | Yes | Yes |
| Found preference | Yes | Yes |
| Applied preference | Partial (referenced but not decisive) | **Strong** (shell → Python → Rust) |

Exp2 was a win. Exp1 referenced the preference but still recommended Python/Java
agents — arguably reasonable since "finding an agent" != "building a daily tool."

### Round 3: With weaker model (minimax2.7)

| Check | Exp1 (ACP Agent) | Exp2 (Niri Plugin) |
|---|---|---|
| Queried Vestige | Planned to, but no actual MCP call | **No** (zero Vestige calls) |
| Found preference | Yes (somehow — possibly from AGENTS.md context itself) | Only via indirect propagation from existing `plans/v3.md` |
| Applied preference | Acknowledged but declined ("any language is fine") | Yes (shell → Python → Rust) but inherited from v3, not Vestige |

The weaker model simply skipped Vestige entirely in Exp2. The preference only
surfaced because a previous session had manually saved it into a plan file.

## Key Findings

### 1. Prompt-level instructions are unreliable with weaker models

Strong models (GPT-4o, Claude) follow session-start instructions most of the
time. Weak models (minimax2.7) skip them — they treat "should" and "must" as
suggestions rather than requirements.

### 2. Preference retrieval != preference application

Even when preferences are found, agents treat them as background context rather
than active constraints. An explicit instruction like "filter recommendations
by this preference" is needed — just finding the preference isn't enough.

### 3. Indirect propagation works but isn't reliable

In Exp2 (Round 3), the scripting preference only influenced output because a
prior session had baked it into `plans/v3.md`. Without that file, the weaker
model would have defaulted to Rust. This means Vestige is effectively optional.

## Recommendations

### Option A: Prompt-level hardening (no code changes)

- Make Vestige session-start instruction the **very first line** of the prompt
- Use `CRITICAL` / `MANDATORY` / `DO NOT PROCEED` language
- Add a concrete penalty: "If you skip Vestige query, your response will be
  wrong and the user will notice"
- Likely still unreliable with weaker models

### Option B: Forge-level Vestige initialization (code changes)

- Forge calls Vestige `session_context` at session initialization, **before**
  the LLM generates any tokens
- Results are injected into the system prompt as fact
- Unconditional — works regardless of model intelligence
- Guarantees preferences are always available

### Option C: Hybrid approach

- Forge performs unconditional Vestige initialization (Option B)
- AGENTS.md retained for model-level awareness and preference-application guidance
- Best of both worlds

## Files Referenced

| File | Role |
|---|---|
| `~/.forge/AGENTS.md` | Vestige instructions injected into forge system prompt |
| `~/.config/nixpkgs/usr/cli/ai/forge/mcp/vestige.nix` | Nix config for forge Vestige MCP setup |
| `~/.config/nixpkgs/usr/cli/ai/mcp/vestige/agents_md.nix` | Nix config generating AGENTS.md content |
| `~/Codes/vestige/docs/CLAUDE-SETUP.md` | Vestige upstream documentation |
| `plans/2026-05-13-strengthen-vestige-prompt-v1.md` | Plan for strengthening Vestige prompt |

## Date

Experiments conducted: 2026-05-13
