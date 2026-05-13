# Goose Custom Provider Context Limit Bug

**Date:** 2026-05-13  
**Issue:** Custom provider `context_limit` is ignored; goose always shows `0/128k` instead of the configured value (e.g., `204800`).

---

## Symptom

When using a custom provider like `custom_minimax` with model `MiniMax-M2.7` and `context_limit: 204800`, goose displays:

```
  ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ 0% 0/128k
```

instead of the expected `0/200k`.

---

## Root Cause

`ModelConfig::with_canonical_limits` at `crates/goose/src/model.rs:113-136` only resolves context limits from **two sources**:

1. **Canonical model registry** — built-in providers (`openai`, `anthropic`, `google`, etc.)
2. **Predefined models** — from the `GOOSE_PREDEFINED_MODELS` environment variable

It **never checks** the `models` array inside declarative/custom provider JSON files (`~/.config/goose/custom_providers/*.json`).

When the model name (`MiniMax-M2.7`) is unknown to both sources, `context_limit` stays `None`, and `ModelConfig::context_limit()` falls back to `DEFAULT_CONTEXT_LIMIT = 128_000` (`crates/goose/src/model.rs:8`).

### Affected code paths

| File | Lines | Purpose |
|------|-------|---------|
| `crates/goose-cli/src/session/builder.rs` | 385-391 | Builds `ModelConfig` when starting a CLI session |
| `crates/goose-cli/src/commands/term.rs` | 293-304 | Prints the initial status bar (`0/128k`) |
| `crates/goose-server/src/routes/agent.rs` | 576-585 | Builds `ModelConfig` in the Desktop/server route |
| `crates/goose/src/providers/provider_registry.rs` | 28-31 | `create_with_default_model` for default model selection |

All of these call `ModelConfig::new(...).with_canonical_limits(provider_name)`, which bypasses custom provider configs.

---

## Where `models` IS used (and where it is not)

The `models` array in `~/.config/goose/custom_providers/custom_minimax.json` is **not completely useless**, but its `context_limit` is **ignored at runtime**.

### Used

| Location | Purpose |
|----------|---------|
| `provider_registry.rs:87-91` | Sets `default_model` from `models.first()` |
| `provider_registry.rs:92-103` | Populates `ProviderMetadata.known_models` |
| `goose-server/src/routes/config_management.rs:393` | Returns model list to Desktop UI |
| `goose-cli/src/commands/configure.rs:449` | Shows models during `goose configure` |

### NOT used

| What is missing | Where it should happen |
|-----------------|------------------------|
| `models[].context_limit` -> `ModelConfig.context_limit` | `ModelConfig::with_canonical_limits` |

---

## Workarounds (no code changes)

### Option 1: `GOOSE_CONTEXT_LIMIT` environment variable

Highest priority. Overrides everything, including canonical limits.

```bash
export GOOSE_CONTEXT_LIMIT=204800
goose session
```

Validation: must be `> 4096`.

### Option 2: `GOOSE_PREDEFINED_MODELS` environment variable

Model-scoped fallback. Checked after canonical registry, before the `128k` default.

```bash
export GOOSE_PREDEFINED_MODELS='[{"name":"MiniMax-M2.7","context_limit":204800}]'
goose session
```

Multiple models:

```bash
export GOOSE_PREDEFINED_MODELS='[
  {"name":"MiniMax-M2.7","context_limit":204800},
  {"name":"MiniMax-Other","context_limit":128000}
]'
```

With provider-specific request parameters:

```bash
export GOOSE_PREDEFINED_MODELS='[{
  "name": "MiniMax-M2.7",
  "context_limit": 204800,
  "request_params": {
    "anthropic_beta": "token-efficient-tools-2025-02-19"
  }
}]'
```

**Note:** `GOOSE_PREDEFINED_MODELS` is read via `std::env::var` directly (`model.rs:21`). It **cannot** be set in `~/.config/goose/config.yaml`; it must be an environment variable.

### Option 3: Wrapper script

```bash
#!/bin/bash
export GOOSE_CONTEXT_LIMIT=204800
exec goose "$@"
```

---

## Relevant source locations

| File | Line(s) | Description |
|------|---------|-------------|
| `crates/goose/src/model.rs` | 8 | `DEFAULT_CONTEXT_LIMIT = 128_000` |
| `crates/goose/src/model.rs` | 19-35 | `GOOSE_PREDEFINED_MODELS` parser |
| `crates/goose/src/model.rs` | 78-110 | `ModelConfig::new_base` — reads `GOOSE_CONTEXT_LIMIT` |
| `crates/goose/src/model.rs` | 113-136 | `ModelConfig::with_canonical_limits` — **the buggy function** |
| `crates/goose/src/model.rs` | 277-279 | `context_limit()` — returns `128_000` fallback |
| `crates/goose/src/config/declarative_providers.rs` | 307-341 | `load_provider` — loads custom provider JSON (not called by `with_canonical_limits`) |
| `crates/goose/src/providers/provider_registry.rs` | 92-103 | Copies `models` into `ProviderMetadata.known_models` |
| `crates/goose-cli/src/commands/term.rs` | 293-304 | Status bar context limit computation |
| `crates/goose-cli/src/session/builder.rs` | 385-391 | Session `ModelConfig` creation |

---

## Proper fix (requires code change)

In `ModelConfig::with_canonical_limits`, after the predefined-models check, add a fallback that loads the declarative provider config and searches its `models` array:

```rust
// Try filling remaining gaps from declarative/custom providers
if self.context_limit.is_none() {
    if let Ok(loaded_provider) =
        crate::config::declarative_providers::load_provider(provider_name)
    {
        if let Some(model_info) = loaded_provider
            .config
            .models
            .iter()
            .find(|m| m.name == self.model_name)
        {
            self.context_limit = Some(model_info.context_limit);
        }
    }
}
```

This would fix the bug for CLI, server, and default-model creation paths in one place.
