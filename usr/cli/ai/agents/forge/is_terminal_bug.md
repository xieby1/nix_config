`is_terminal` causes two strange symptoms of forge, which will show under qemu-user and nix-on-droid

by copilot + gpt5.4

# Forge aarch64 freeze under qemu-user

## Root cause

Forge uses stdin for two different purposes:

1. **Piped input ingestion at startup**: in `crates/forge_main/src/main.rs`, Forge checks `stdin.is_terminal()`. If that is `false`, it calls `read_to_string()` on stdin and stores the result as `cli.piped_input`.
2. **Interactive terminal input later**: the REPL and prompt widgets use `reedline` / `rustyline` to read from the terminal.

The freeze happens in the **startup piped-input path**, not in the chat request itself.

Under the aarch64 binary running through **qemu-user + binfmt**, stdin appears to be misdetected:

- Forge sees `stdin.is_terminal() == false`
- Forge therefore assumes stdin is piped input
- Forge calls `read_to_string()` on fd 0
- `read_to_string()` waits for **EOF**
- on an interactive TTY, EOF never arrives unless the user explicitly sends it

So Forge appears to freeze before printing anything meaningful.

This explains the observed behavior:

- `forge` freezes because it tries to drain interactive stdin
- `forge --version` works because Clap exits before Forge reaches that logic
- `echo | forge` works differently because stdin reaches EOF immediately
- `forge -p hello` still freezes because the stdin-drain logic runs before the prompt is handled
- `echo | forge -p hello` works because stdin is closed immediately, so startup continues

## Detailed explanation of the fix

The current logic is too coarse:

```rust
if !stdin.is_terminal() {
    read_all_stdin();
}
```

That treats all non-terminal stdin sources as equivalent, but they are not:

| stdin source | `is_terminal()` | should Forge drain it? |
|---|---:|---:|
| real tty / pty | usually true, but false in this broken case | no |
| pipe (`echo hi \| forge`) | false | yes |
| file (`forge < prompt.txt`) | false | yes |
| socket | false | yes |
| character device | false in some edge cases | usually no |

The fix is to distinguish **real streams** from **generic character devices**.

### Proposed Unix logic

1. If `stdin.is_terminal()` is `true`, treat stdin as interactive and do not drain it.
2. If `stdin.is_terminal()` is `false`, call `fstat(0)`.
3. Inspect `st_mode & S_IFMT`.
4. Only call `read_to_string()` when stdin is **not** `S_IFCHR`.

That means:

- `S_IFIFO` (pipe) -> read
- `S_IFREG` (file) -> read
- `S_IFSOCK` (socket) -> read
- `S_IFCHR` (character device, including tty-like fds) -> do **not** read

### Why this works better

`is_terminal()` is a behavioral test. In the qemu-user setup it appears unreliable for this aarch64 process.

`fstat(0)` provides a structural check from the kernel: it tells Forge what kind of fd stdin actually is.

Even if `is_terminal()` incorrectly returns `false`, a tty / pty still shows up as a **character device** (`S_IFCHR`), which lets Forge avoid draining it as if it were a pipe.

So the new rule is:

> Only auto-consume stdin when stdin is a real stream source for content injection, not when it is merely a character device.

### Behavior preserved by the fix

- `echo hello | forge` still works
- `forge < prompt.txt` still works
- socket-fed stdin still works
- interactive `forge` no longer blocks in startup stdin draining
- `forge -p hello` no longer blocks in startup stdin draining

### Important limitation

This fix specifically addresses the **startup freeze** in `main.rs`.

If qemu-user also breaks later terminal behavior inside `reedline` / `rustyline`, the fully interactive REPL may still have separate issues. In other words:

- startup hang: this fix should address it
- interactive line editing problems after startup: may require additional debugging

## Implementation sketch

Conceptually:

```rust
enum StdinKind {
    Terminal,
    CharacterDevice,
    Stream,
}

fn should_read_piped_input(kind: StdinKind) -> bool {
    matches!(kind, StdinKind::Stream)
}
```

Unix detection:

```rust
if stdin.is_terminal() {
    StdinKind::Terminal
} else {
    match fstat(0) {
        S_IFCHR => StdinKind::CharacterDevice,
        _ => StdinKind::Stream,
    }
}
```

And then:

```rust
if should_read_piped_input(detect_stdin_kind()?) {
    stdin.read_to_string(...)
}
```

## Tradeoff

`/dev/null` is also `S_IFCHR`, so Forge would no longer eagerly drain it.

That is acceptable here because draining `/dev/null` only produces empty input anyway, and the important goal is to stop misclassified TTYs from blocking forever.

# `forge cmd execute model` does not show

After removing the startup `is_terminal()`-based stdin drain, Forge can get past initialization, but `forge cmd execute model` still does not behave correctly under the same qemu-user setup.

## Observed behavior

- `forge list model --porcelain` works and prints the available models
- `forge config get provider` and `forge config get model` show valid session configuration
- `forge cmd execute model` prints the `Initialize ...` line and then exits with code `0`
- no model picker is shown
- `strace` shows that `fzf` is never launched

This means the command is **not** hanging while loading models. Instead, the interactive selection path returns early as if the user cancelled the picker.

## Command path

The command flow is:

1. `forge cmd execute model`
2. `TopLevelCommand::Cmd`
3. `CmdCommand::Execute`
4. command string becomes `/model`
5. `/model` maps to `AppCommand::Model`
6. `AppCommand::Model` calls `self.on_model_selection(None).await?`
7. `on_model_selection()` calls `select_model()`
8. `select_model()` builds the list of models successfully and then calls the interactive selector

The model data path itself is working because `self.api.get_all_provider_models().await?` succeeds and `forge list model --porcelain` also succeeds.

## Where it fails

The failure is in the shared interactive widget layer, not in model loading.

`select_model()` eventually calls:

```rust
ForgeWidget::select("Model", rows)
    .with_starting_cursor(starting_cursor)
    .with_header_lines(1)
    .prompt()?
```

But `forge_select::SelectBuilder::prompt()` still contains:

```rust
if !std::io::stdin().is_terminal() {
    return Ok(None);
}
```

Under qemu-user, stdin is again being misdetected as non-terminal, so the selector returns `Ok(None)` immediately.

That `None` propagates upward as:

- “no selection”
- treated like “user canceled”
- no error is printed
- process exits successfully

This exactly matches the observed behavior.

## Why `fzf` never appears

Because the code bails out **before** trying to launch `fzf`.

So this is not:

- a model API failure
- an empty model list
- an `fzf` startup failure

It is the same TTY misdetection problem, but now inside `forge_select`.

## Affected widget paths

The same pattern still exists in:

- `crates/forge_select/src/select.rs`
- `crates/forge_select/src/multi.rs`
- `crates/forge_select/src/input.rs`

So even if the startup stdin logic in `main.rs` is fixed, interactive Forge widgets can still silently fail under qemu-user until these TTY guards are updated too.

## Correct fix direction

The same stronger stdin classification used for the startup fix should also be applied to the widget layer.

Instead of:

```rust
if !std::io::stdin().is_terminal() {
    return Ok(None);
}
```

use a shared helper that:

1. returns interactive if `stdin.is_terminal()` is true
2. otherwise uses `fstat(0)`
3. treats `S_IFCHR` as interactive
4. only treats true stream inputs (pipe/file/socket) as non-interactive

Conceptually:

```rust
if !stdin_is_interactive()? {
    return Ok(None);
}
```

## Summary

The original startup freeze and the `cmd execute model` problem have the same root family:

- qemu-user misreports a tty-like stdin as non-terminal

But they hit different code paths:

- startup freeze: `crates/forge_main/src/main.rs`
- missing model picker: `crates/forge_select/src/select.rs`

So fixing only `main.rs` is not enough. The interactive selection/input widgets must also stop relying on raw `stdin.is_terminal()` checks.

# How the root causes were located

## Symptom 1: Forge aarch64 freeze

The debugging process for the startup freeze followed a narrowing sequence:

1. First compare multiple entry modes:
   - `forge` freezes
   - `forge --version` works
   - `forge -p hello` freezes
   - `echo | forge` behaves differently
   - `echo | forge -p hello` works

   This immediately suggested that the problem depends on **how stdin is attached**, not on the core model API or binary loading.

2. Then inspect the startup code for stdin handling.

   `crates/forge_main/src/main.rs` contains an early branch:

   ```rust
   if !std::io::stdin().is_terminal() {
       std::io::stdin().read_to_string(&mut stdin_content)?;
   }
   ```

   That code runs before the UI starts, so it was a strong candidate for a startup freeze.

3. Next use `strace` on the failing case.

   For `forge -p hello`, the traced process did not produce meaningful output and blocked on a read from fd 0. That matched the behavior of `read_to_string()`, which waits for EOF.

4. Then compare against the piped case.

   In the piped case, stdin immediately reaches EOF, so the same startup branch completes and Forge continues. That explained why `echo | forge -p hello` works while `forge -p hello` freezes.

5. Finally check the code paths that should have run later.

   The later interactive UI and prompt code could not explain why the process stalled before doing useful output. The early stdin-drain branch explained the full symptom matrix much better.

That is how the investigation converged on:

- `stdin.is_terminal()` is wrong under qemu-user for this aarch64 process
- Forge incorrectly enters the piped-input code path
- `read_to_string()` blocks forever on interactive stdin

## Symptom 2: `forge cmd execute model` shows nothing

The debugging process for the missing model picker followed a similar elimination path:

1. First reproduce the behavior carefully.

   The command:

   ```bash
   forge cmd execute model
   ```

   printed only the `Initialize ...` line and then exited successfully with no picker shown.

2. Then verify that model data itself is available.

   These checks worked:

   - `forge config get provider`
   - `forge config get model`
   - `forge list model --porcelain`

   So the problem was clearly **not** “no provider configured” or “failed to load models”.

3. Next trace the command path in the source.

   The flow was:

   - `TopLevelCommand::Cmd`
   - `CmdCommand::Execute`
   - parsed into `/model`
   - mapped to `AppCommand::Model`
   - which calls `on_model_selection(None)`
   - which calls `select_model()`
   - which builds model rows and then invokes `ForgeWidget::select(...).prompt()?`

   This showed that model loading and model-row construction both happen before the interactive widget.

4. Then use `strace` to check whether `fzf` is actually launched.

   It was not. No `execve()` of `fzf` appeared.

   That ruled out:

   - an `fzf` rendering problem
   - a blocked `fzf` terminal session
   - a failure after launching the picker

5. Then inspect the shared widget implementation.

   `forge_select::SelectBuilder::prompt()` still had:

   ```rust
   if !std::io::stdin().is_terminal() {
       return Ok(None);
   }
   ```

   So if qemu-user misreports stdin again, the widget simply returns `None`, which the caller interprets as “user canceled”.

6. Finally compare this behavior with the observed result.

   That exact code path explains:

   - no picker appears
   - no error is shown
   - exit code is 0
   - `fzf` is never executed

That is how the investigation converged on the second root cause:

- the startup stdin bug was only one instance
- the same `is_terminal()` misdetection still exists inside `forge_select`
- `cmd execute model` fails silently because the selector bails out before opening `fzf`

## General lesson from both symptoms

The important debugging pattern was:

1. compare working and failing invocation forms
2. identify whether the difference is stdin/TTY-related
3. inspect the earliest code that branches on stdin
4. confirm with `strace` whether the process blocks, exits, or launches child tools
5. only then map the runtime behavior back to the exact source location

Both symptoms looked different on the surface:

- one freezes
- one exits quietly

But the investigation showed they are both consequences of the same underlying issue:

- `stdin.is_terminal()` is unreliable for this qemu-user aarch64 environment
