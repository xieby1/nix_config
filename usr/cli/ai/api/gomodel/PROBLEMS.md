# GoModel Problems

## Codex CLI + Anthropic models: "unsupported tool type"

Codex CLI (v0.118.0+) only supports `wire_api = "responses"` and sends non-function tool types (e.g. `container`) in requests. GoModel's Anthropic provider rejects any tool where `type != "function"` (`internal/providers/anthropic/request_translation.go:93`).

The Responses-to-Chat adapter (`normalizeResponsesToolForChat`) passes non-function tools through unchanged, and `convertOpenAIToolsToAnthropic` then errors out.

**Affected models:** `jw-claude/*`, `deepseek/*` — anything behind a non-OpenAI provider.
**Working models:** `jw-codex/*` (native OpenAI provider handles Responses API natively).

**Fix options:**
1. Skip/filter unsupported tool types instead of erroring (Anthropic has no equivalent for `container` etc.)
2. Map them to Anthropic equivalents where possible (e.g. `computer_use`)
