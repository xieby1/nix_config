# Agents Comparisons

## Opencode

- Pros:
  - Javascript based. The nix closure is not so large: 186MB!
- Cons:
  - Javascript based. The memory consumption of open a new opencode instance: ~500MB
  - Use Esc instead of Ctrl-C to interrupt.
- Summary: Its quality is not comparable to neovim,
           though it declares "OpenCode is built by neovim users ...".

## Crush

- Pros:
  - Go lang based.
    - Small nix-closure.
    - Small memory consumption: crush instance that have several conversations: ~70MB
- Cons:
  - It's Ok for me now ~~Token inefficiency: 300 line system prompt and cannot fully customize,
                        only supports system prompt prefix.~~
  - The input line support Home, End key, but does not support Ctrl+Left/Right.
  - It's Ok for me now ~~Does not support terminal scrollback.~~
  - It's Ok for me now ~~Notification cannot click and jump to the corresponding terminal.~~
  - I need auto generating skill, so this is unnecessary now
    ~~Does not support explicit skill: https://github.com/charmbracelet/crush/discussions/2505 and no discussions!~~
  - Generate `.crush/` in every folder where crush launched

## Aider

- Pros:
  - Support script
  - Token efficiency
    - Test Prompt: Introduce yourself
      - Aider: 2.3k
      - Crush: 15K
  - Native input line support: scrollback, Ctrl-Left/Right, ...
- Cons:
  - Python based, large codebase: nix closure > 2GB
  - Does not support skill, memory.
  - Models are out of date, e.g.: minimax 2.5, while latest is 2.7

## Codex

- Cons:
  - Latest versions only support wire_api = "responses",
    does not support completion.
    So does not support deepseek, minimax, ....
    Fine!
  - 603k source lines of rust, a pile of xxxx.

## Code (Codex Fork)

- Pros:
  - Support wire_api = "chat"
- Cons:
  - A fork that always needs to rebase.

## Forgecode

- Pros:
  - Moved to AAIF at Linux Foundation: more stable, more reliable
- Cons:
  - Claims being #1. Really?
  - Fixed: ~The global local is ~/forge/, really!? I doubt the project's taste of tech.~~
  - Does not support prompt injection, e.g. hook scripts.
    - The pull request is stale
      - https://github.com/tailcallhq/forgecode/issues/2562
      - https://github.com/tailcallhq/forgecode/pull/2757
  - Does not support ACP, and the pull request is stale.

## Goose

- Cons:
  - Fixed: ~~Why goose does not saved in nix binary cache, and 1.23.2 cannot build in x86-64 Linux: checkPhase failed!?~~
    ~~Why the compiling time so long 7min+?~~
  - Fixed: ~~Why the output color render bug remain unsolved?~~
    **VERY IMPORTANT**: **Oh, I guess this project focus on desktop, instead of cli.**
  - zsh cursor sometimes disappear?
  - `goose configure` cannot configure kimi, minimax successfully, only by manually add a custom_xxx.json
  - minimax is still 2.5
    - https://github.com/aaif-goose/goose/pull/7981
  - cannot switch model during conversation
    - https://github.com/aaif-goose/goose/pull/8747
  - the context length is wrong
    - goose/2026-05-13-custom-provider-context-limit-bug.md

## Hermes

- Cons:
  - Declare able to self-improvement (auto skill generating), but does not support per-project skill yet!?
    https://github.com/NousResearch/hermes-agent/issues/4667
    In my humble opinion, a auto-generating-skill skill is enough!
  - Why CLI+TUI? Why not unify them? split experience, split community?
    - TUI
      - scroll glitch
      - does not filter configured providers/models when selecting them, however CLI does.
    - CLI
      - resize => re-render
      - resume does not support selection UI, but TUI does.
  - Too many bugs that influence my experience, see my patches.

## VTCode

- Pros:
  - Author response very quickly.
- Cons:
  - Single person maintained
  - ctrl-g does not run async
  - config files in a mess: `~/.config/vtcode/config.toml`, `~/.config/vtcode/vtcode.toml`, `~/.vtcode/`

## pi

- Pros:
  - minimalist
- Cons:
  - minimalist: lack of many features
    - lack of high-quality plugins such as memory, plan, subagents.
  - typescript-based

## pi_agent_rust

- Cons:
  - Single developer, thus less reliable.

## nvim

### Avante.nvim

- Pros:
  - Leverages Neovim muscle memory
- Cons:
  - ~~No skills support~~ Supported by ACP agents.
  - Uses plenary.nvim (curl without keepalive or auto-retry)
    - Frequent network issues cause interruptions that disrupt workflow
  - Second class ACP support: does not support ACP model switch.
    - Latest version add `AvanteACPModels`. Why not reusing `AvanteModels`? The implementation is not CLEAN!
  - The build is complicated (nixpkgs vim plugins non-generated), which has not updated for 3 months.

### Codecompanion.nvim

- Pros:
  - Leverages Neovim muscle memory
  - Minimal/Clean UI
  - Support more ACP capabilities than Agentic.nvim: fs.readTextFile, fs.writeTextFile
    And it explicitly state support of ACP capabilities in doc!
  - build is simple
- Cons:
  - ~~No skills support~~ Supported by ACP agents.
  - ~~Use plenary.nvim, the same to Avante.nvim.~~: Use ACP agent!
  - ~~Codecompanion-history does not support ACP session restore.~~: If ACP client supports, we can use `/resume`!
  - tool calls display are trunct to 60 chars, and no way to configure it.

### Agentic.nvim

- Pros:
  - simple and only cares about ACP
- Cons:
  - does not support any ACP capabilities, including fs.readTextFile, fs.writeTextFile, terminal.
    And it does not mentioned not support above ACP capabilities in doc.
  - Bugs:
    - when enter slash command like `/skill`, there is high, narrow auto completion floating window.
    - Cannot disable insert by default
    - Cannot hide winbar (need to edit source code)

## TODO: zot

- https://news.ycombinator.com/item?id=48319524
- Pros:
  - extensions in any language via subprocess + json-rpc
- Cons:
  - Does not support ACP
  - Does not support MCP

## TODO: zerostack

- https://news.ycombinator.com/item?id=48164287
- Cons:
  - The discussions/plans are the explicit: e.g. [Make zerostack extensible](https://github.com/gi-dellav/zerostack/issues/108)
  - Does not support hooks
  - Does not support per-model context window
  - ACP support incomplete: session resume, model switch
  - Explicitly state that skills is not supported. It prefer prompts.
