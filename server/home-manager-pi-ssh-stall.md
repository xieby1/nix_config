# Home Manager Pi Import SSH Stall

## Problem

On `my-server`, enabling this import in `server/default.nix` can make `home-manager switch` appear to fail and the SSH connection drop:

```nix
../usr/cli/ai/agents/pi
```

With the import commented out, `home-manager switch` completes normally.

## Observed Behavior

- `ssh my-server` or `ssh my-server 'cmd'` may disconnect or stall while Home Manager is running.
- The server remains alive, but SSH may be too slow to start a session or complete a command.
- Swap is enabled but can remain unused:

```text
/swapfile  4G  0B used
```

- Kernel logs did not show a fatal OOM kill for the investigated runs.
- Journal logs did show repeated memory pressure messages, for example:

```text
systemd-journald: Under memory pressure, flushing caches.
```

## Cause

The Pi import pulls a large set of packages and extension derivations into the Home Manager generation, including Pi, Node/npm packages, Python packages, compiler/toolchain pieces, and Pi extensions such as:

- `pi`
- `pi-acp`
- `pi-mcp-adapter`
- `pi-hermes-memory`
- `rpiv-todo`

On a small VPS, trying to download, substitute, unpack, or build these paths during `home-manager switch` can create enough memory, I/O, network, and process-spawning pressure that `sshd` becomes unresponsive long enough for the SSH client to time out.

This is resource starvation, not necessarily an OOM kill.

## Why Swap Can Stay at 0

Linux does not immediately use swap whenever the system is under pressure. It first tries to reclaim page cache, filesystem cache, slab cache, clean mapped pages, and other reclaimable memory.

So this combination is possible and was observed:

- memory pressure exists,
- no process is OOM-killed,
- SSH becomes unresponsive,
- swap usage remains `0B`.

Swap is not a guarantee that the machine remains interactive during heavy Nix builds or large substitutions.

## Recommended Procedure

Do not build the Pi closure on `my-server` when it can be avoided. Build locally and copy the closure:

```bash
home-manager build
nix-copy-closure --to my-server /nix/store/<pi-related-paths>
```

For the investigated generation, copying these local outputs made the temporary Home Manager build with Pi succeed on `my-server`:

```text
pi
pi-acp
pi-mcp-adapter
pi-hermes-memory
rpiv-todo
```

Prefer `nix-copy-closure` for this workflow. Do not push these paths to Cachix unless explicitly intended.

## If Building on the Server Is Unavoidable

Run in `tmux` so the command survives a client disconnect:

```bash
tmux new -s hm
source ~/.config/nixpkgs/scripts/bootstrap/main.sh
NIX_CONFIG='max-jobs = 1
cores = 1' home-manager switch
```

Reconnect with:

```bash
tmux attach -t hm
```

`tmux` only protects the session. It does not solve the resource pressure. Use `max-jobs = 1` and `cores = 1` to reduce the chance that Nix starves `sshd`.

## Useful Diagnostics

Check swap and memory:

```bash
swapon --show
free -h
```

Check for actual OOM kills:

```bash
journalctl -b --no-pager | grep -iE 'oom|out of memory|killed process'
```

Check for pressure without OOM:

```bash
journalctl -b --no-pager | grep -i 'memory pressure'
```

Check active Nix/Home Manager work:

```bash
ps -eo pid,ppid,stat,etime,rss,cmd | grep -E 'home-manager|nix-build|nix |node|npm|cc1|g\+\+'
```
