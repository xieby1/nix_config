# Hermes Agent TODO

## TUI tool call preview truncation

The TUI (hermes-tui v2026.4.30) ignores `display.tool_preview_length: 0` config.

- `formatToolCall()` in `lib/text.js` hardcodes `compactPreview(context, 64)` — caps tool call arguments to 64 chars regardless of config.
- Tool results (`msg.role === 'tool'` in `messageLine.js`) are rendered as a single `truncate-end` line, so multi-line results (e.g. search_files JSON) may not display at all.
- The Python backend correctly sends full text when `tool_preview_length: 0`, but the TUI re-truncates on render.

**Affected files (in hermes-tui source):**
- `dist/lib/text.js:96` — `compactPreview(context, 64)`
- `dist/components/messageLine.js:61-80` — tool result display

**Workaround:** Use CLI mode (`hermes` without `--tui`) or `/details full`.
