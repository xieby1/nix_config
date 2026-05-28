# Codex Problems

## Cannot switch to custom models from within the TUI

**Location:** `codex-rs/tui/src/chatwidget/model_popups.rs`, `codex-rs/tui/src/slash_command.rs`

**Description:**
The `/model` slash command only shows a picker populated from the server-provided `ModelCatalog` (a fixed list of `ModelPreset` entries). There is no free-text input to type an arbitrary model name. The underlying `AppEvent::UpdateModel(String)` event accepts any string, but it is only ever fired from preset selections — there is no UI path that lets a user supply a custom model identifier at runtime.

**Impact:**
Users who rely on custom or self-hosted models (e.g. via a custom `base_url`) cannot switch between them interactively. They must restart the TUI with `codex -m <model_name>` or manually edit `config.toml` while the TUI is running.

**Workarounds:**
- Pass the model at startup: `codex -m <model_name>`
- Set `model` in `config.toml` before launching
- Edit `config.toml` while the TUI is running (the TUI picks up config changes via `write_config_batch`)

**Suggested fix:**
Add a "Custom model…" entry at the bottom of the `/model` picker that opens a free-text input prompt. On confirmation, fire `AppEvent::UpdateModel` and `AppEvent::PersistModelSelection` with the entered string, matching the existing flow used by preset selections.
