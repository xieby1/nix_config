# Zsh Completion in NixOS

## Overview

In NixOS, zsh completion functions are discovered through a combination of:

- The `fpath` variable configured by the NixOS zsh module
- The `NIX_PROFILES` environment variable
- The `environment.pathsToLink` NixOS option

## How It Works

### 1. Zsh `fpath` Configuration

The NixOS zsh module (`nixos/modules/programs/zsh/zsh.nix:198-202`) injects the following into every interactive zsh shell:

```zsh
# Tell zsh how to find installed completions.
for p in ${(z)NIX_PROFILES}; do
  fpath=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions $fpath)
done
```

This tells zsh to search for completion functions under `share/zsh/` within each profile directory.

### 2. `NIX_PROFILES`

`NIX_PROFILES` is an environment variable set by NixOS that contains a space-separated list of profile directories, typically including:

- `/run/current-system/sw` (system packages)
- User profiles (e.g., `$HOME/.nix-profile`)

### 3. `environment.pathsToLink`

NixOS does **not** symlink every file from every installed package into `/run/current-system/sw`. Instead, it uses a whitelist approach via `environment.pathsToLink` (`nixos/modules/config/system-path.nix:134-141`).

The zsh module adds:

```nix
environment.pathsToLink = lib.optional cfg.enableCompletion "/share/zsh";
```

(`nixos/modules/programs/zsh/zsh.nix:314`)

This ensures that `share/zsh/` directories from all packages in `environment.systemPackages` are symlinked into `/run/current-system/sw/share/zsh/`, making them discoverable by zsh via `fpath`.

## Why This Matters

Without `environment.pathsToLink = ["/share/zsh"]`:

- Packages like `git`, `nix-zsh-completions`, etc. would install their completion files in the Nix store
- But no symlinks would exist at `/run/current-system/sw/share/zsh/`
- Zsh would search the paths in `fpath` and find nothing
- Tab completion for system packages would not work

## Default Paths Linked by NixOS

NixOS links a sensible set of directories by default (`nixos/modules/config/system-path.nix:188-205`):

```nix
environment.pathsToLink = [
  "/bin"
  "/etc/xdg"
  "/etc/gtk-2.0"
  "/etc/gtk-3.0"
  "/lib"
  "/sbin"
  "/share/emacs"
  "/share/hunspell"
  "/share/org"
  "/share/themes"
  "/share/vulkan"
  "/share/kservices5"
  "/share/kservicetypes5"
  "/share/kxmlgui5"
  "/share/systemd"
  "/share/thumbnailers"
];
```

Note that `/share/zsh` is **not** in this default list — it is added by the zsh module only when completion is enabled.

## Key Code Locations

| File | Lines | Description |
|------|-------|-------------|
| `nixos/modules/config/system-path.nix` | 134-141 | `environment.pathsToLink` option definition |
| `nixos/modules/config/system-path.nix` | 188-205 | Default `pathsToLink` values |
| `nixos/modules/programs/zsh/zsh.nix` | 198-202 | `fpath` configuration in zsh init |
| `nixos/modules/programs/zsh/zsh.nix` | 314 | Zsh module adding `/share/zsh` to `pathsToLink` |
| `pkgs/build-support/buildenv/default.nix` | 42-45 | `buildEnv` `pathsToLink` parameter documentation |
