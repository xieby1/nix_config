2026.05.24: by hermes + gpt-5.5

# LLM API Families, LiteLLM, Codex Responses API, and Compiled-Language Gateway Alternatives

## Why “completions API” is confusing

“Completion” is used in at least three ways:

1. **Generic generation concept**: a model completes/generates output.
2. **Legacy OpenAI Completions API**: `POST /v1/completions`, prompt string in, text string out.
3. **OpenAI Chat Completions API**: `POST /v1/chat/completions`, role-tagged messages in, assistant message out.

So always distinguish:

```text
/v1/completions       = legacy prompt completions
/v1/chat/completions  = chat completions
/v1/responses         = new agent-oriented Responses API
```

## Mainstream LLM API families

| Family | Endpoint examples | Input shape | Agent suitability | Status |
|---|---|---|---:|---|
| Legacy prompt completions | `/v1/completions`, Ollama `/api/generate` | single prompt string | Poor | Legacy/simple generation |
| Chat Completions | `/v1/chat/completions` | `messages[]` with `system/user/assistant/tool` roles | Good | Very common compatibility target |
| Messages API | Anthropic `/v1/messages` | provider-specific `messages[]`; separate system prompt | Good | Anthropic-style modern API |
| Responses API | OpenAI `/v1/responses` | structured `input[]` / output items | Best | OpenAI’s new direction, used by new Codex |
| Gemini native | `models/{model}:generateContent`, `:streamGenerateContent` | `contents[]` with `parts[]` | Good | Google-native API |
| Bedrock Converse | `Converse`, `ConverseStream` | AWS unified message/tool schema | Good | AWS cross-model API |
| Provider-specific invoke | Bedrock `InvokeModel`, custom JSON APIs | arbitrary provider schema | Varies | Low-level escape hatch |
| Local runtime APIs | Ollama `/api/chat`, vLLM/llama.cpp OpenAI-compatible servers | varies | Varies | Common for local models |

## Compiled-language alternatives to LiteLLM

||| Project | Language | Closest to LiteLLM? | Main focus | Notes for Codex `/v1/responses` |
|---|---|---|---|---:|---|---|
||| **GoModel** | Go | Very close | Lightweight multi-provider AI gateway (~17 MB image, semantic caching, usage tracking) | OpenAI-compatible passthrough; verify Responses API and streaming/tool parity |
||| **Bifrost** | Go | Very close | High-performance multi-provider AI gateway | Promising; verify Responses API and streaming/tool parity |
||| **Barbacane** | Rust | Close | Spec-driven API gateway with bidirectional AI + MCP support | OpenAPI-spec-as-config; `ai-proxy` plugin supports Chat Completions + stateless Responses API; verify streaming/tool parity |
||| **OmniRoute** | Node.js/TypeScript | Close | Free self-hosted AI gateway (160+ providers, 13 routing strategies, semantic cache, MCP) | MIT license; npm/Docker/Electron/Termux deploy; verify Responses API support |
||| **Hecate** | Go | Close | Local-first AI runtime console + gateway for cloud/local models | Coding-agent console, task approvals, OpenTelemetry; early stage (16 stars); verify maturity |
||| **Traceloop Hub** | Rust | Close | LLM gateway + OpenTelemetry observability | Docs emphasize chat/completions; verify Responses API |
||| **Envoy AI Gateway** | Go control plane + Envoy/C++ data plane | Close, infra-native | Kubernetes/Envoy LLM gateway | Good infra story; verify Responses transform support |
||| **AISIX** | Rust | Close but young | Rust AI gateway / LLM proxy | Promising; verify maturity and Responses API |
||| **LocalAI** | Go + native backends | Partial | Local model serving with OpenAI-compatible API | Useful for local inference, not a pure multi-provider gateway |
||| **Kong AI Gateway** | Nginx/OpenResty/Lua ecosystem, Go components | Partial/enterprise | API gateway with AI plugins | Strong gateway features, not a simple LiteLLM clone |
||| **Apache APISIX AI Gateway** | OpenResty/Lua + etcd ecosystem | Partial/infra | API gateway with AI plugins | Infra-grade, less automatic provider normalization |
||| **agentgateway** | Rust | Partial | AI-native proxy for LLM/MCP/agent traffic | Interesting for agent/MCP traffic; verify LLM provider breadth |

## Recommendation

If the goal is "LiteLLM but compiled-language and lower overhead," evaluate in this order:

1. **GoModel** — smallest footprint (~17 MB), semantic caching, usage tracking, fully OSS.
2. **Bifrost** — closest conceptual Go replacement; production-grade with MCP support.
3. **Barbacane** — Rust-native, spec-driven (OpenAPI-as-config), bidirectional AI + MCP gateway; best if you already use OpenAPI specs and want AI traffic governed same as other HTTP traffic.
4. **OmniRoute** — MIT-licensed, 160+ providers, 13 routing strategies, semantic cache, MCP; TypeScript-based but self-hostable via npm/Docker.
5. **Hecate** — local-first Go runtime with coding-agent console; early stage but interesting for agent workloads.
6. **Traceloop Hub** — Rust gateway with observability.
7. **AISIX** — Rust, promising but younger.
8. **Envoy AI Gateway** — best if running Kubernetes/Envoy and wanting infra-grade control.

If the goal is specifically **new Codex compatibility**, the decisive requirement is:

```text
Does the gateway expose /v1/responses and correctly translate streaming/tool-call events?
```

A fast Go/Rust gateway that only supports `/v1/chat/completions` will not by itself solve the new Codex problem.
