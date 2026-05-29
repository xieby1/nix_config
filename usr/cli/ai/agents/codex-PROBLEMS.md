# Codex Problems

## Cannot switch arbitrary custom model IDs in the TUI

**Files:**
- `codex-rs/tui/src/chatwidget/model_popups.rs`
- `codex-rs/tui/src/slash_command.rs`
- `codex-rs/tui/src/chatwidget/slash_dispatch.rs`
- `codex-rs/tui/src/app/event_dispatch.rs`
- `codex-rs/tui/src/app/thread_settings.rs`
- `codex-rs/app-server/src/request_processors/turn_processor.rs`
- `codex-rs/core/src/codex_thread.rs`

**Problem:**
`/model` only shows visible `ModelPreset`s from the resolved model catalog (`try_list_models()` + `show_in_picker`). There is no `/model <model_id>` path and no free-text "Custom model…" picker entry.

The runtime path can already accept arbitrary model strings:
`AppEvent::UpdateModel(String)` → `thread/settings/update` → `Op::ThreadSettings` → `collaboration_mode.with_updates(model, effort, ...)`.

So the small missing piece is UI/command input for an arbitrary model ID.

**Important limitation:**
This is model-string switching only. `UpdateModel` does not switch `model_provider`. Switching providers/profiles in-session is a separate, larger problem and may require a new/forked session to avoid provider/auth/history incompatibilities.

**Impact:**
Custom/self-hosted model users cannot switch among uncataloged model IDs interactively. They must restart or preconfigure the desired model/catalog.

**Workarounds:**
- Start with `codex -m <model_name>`.
- Start with `codex -p <profile>` for provider+model.
- Set `model` / `model_provider` in `config.toml` before launch.
- Use startup-only `model_catalog_json` so custom models appear in `/model`.

**Related upstream issues:**
- `openai/codex#5841`: dynamic custom model switching; closed not planned.
- `openai/codex#22160`: expose profiles/custom aliases in pickers; closed not planned.
- `openai/codex#24659`: custom models not loaded from `models_cache.json`; `model_catalog_json` workaround.
- `openai/codex#24612`: cross-provider switching can fail due to incompatible history items.

**Suggested minimal fix:**
Support inline model args:

```text
/model <model_id>
```

Implementation:
1. Add `SlashCommand::Model` to `supports_inline_args()`.
2. In `slash_dispatch.rs`, handle non-empty `/model` args.
3. Dispatch `UpdateModel(model)` and `PersistModelSelection { model, effort: None }`.
4. Warn/document that this changes only the model string for the current provider.

**Optional UI fix:**
Add "Custom model…" to the `/model` picker and reuse the same helper as `/model <model_id>`.
