# Bash to Zsh Migration Checklist

Generated for home-manager configuration at `~/.config/nixpkgs`.

---

## Phase 0: Understand Current State

- [ ] Review current bash config: `usr/cli/default.nix` (lines 150-204)
- [ ] Review zsh config: `usr/cli/zsh/default.nix`
- [ ] Review bash-to-zsh forwarding: `usr/cli/zsh/bash-zsh-forward.nix`
- [ ] Audit all `programs.bash.shellAliases` across the codebase:
  - `usr/cli/default.nix:222`
  - `usr/cli/git.nix:58`
  - `usr/cli/vim/default.nix:50,54`
  - `usr/cli/vim/codecompanion-nvim/default.nix:108`
  - `usr/cli/vim/lz-n/fugit2.nix:28`
- [ ] Audit all `programs.bash.bashrcExtra` injections:
  - `usr/cli/default.nix:151`
  - `usr/cli/tmux.nix:8`
  - `usr/cli/ssh.nix:35`
  - `usr/cli/clash.nix:18`
  - `usr/cli/fzf.nix:48`
  - `usr/cli/tailscale.nix:69`
  - `usr/cli/vim/nvim-lspconfig/scala.nix:67`
- [ ] Check `programs.zsh.initContent` in `usr/default.nix:21`

---

## Phase 1: Migrate Shell Aliases

Goal: Move from `programs.bash.shellAliases` to `home.shellAliases` so both shells can share them during transition.

- [ ] `usr/cli/default.nix`: Change `programs.bash.shellAliases.cat` to `home.shellAliases.cat`
- [ ] `usr/cli/git.nix`: Change `programs.bash.shellAliases.mr` to `home.shellAliases.mr`
- [ ] `usr/cli/vim/default.nix`: Change `programs.bash.shellAliases.view` to `home.shellAliases.view`
- [ ] `usr/cli/vim/default.nix`: Change `programs.bash.shellAliases.nman` to `home.shellAliases.nman`
- [ ] `usr/cli/vim/codecompanion-nvim/default.nix`: Change `programs.bash.shellAliases.codecompanion` to `home.shellAliases.codecompanion`
- [ ] `usr/cli/vim/lz-n/fugit2.nix`: Change `programs.bash.shellAliases.fugit2` to `home.shellAliases.fugit2`
- [ ] `usr/cli/default.nix`: Move the inline `alias ls=eza` from `bashrcExtra` (lines 197-199) to `home.shellAliases.ls`

---

## Phase 2: Migrate Environment Variables

Goal: Move exports from `bashrcExtra` to `home.sessionVariables` / `home.sessionVariablesExtra`.

- [ ] Add to `home.sessionVariables`:
  ```nix
  NIXPKGS_ALLOW_INSECURE = "1";
  NIX_USER_CONF_FILES = "\${config.home.homeDirectory}/.config/nixpkgs/nix/nix.conf";
  LANG = "C.UTF-8";
  ```
- [ ] Migrate `XDG_DATA_DIRS` append logic to `home.sessionVariablesExtra` or `programs.zsh.envExtra`
- [ ] Remove the above `export` statements from `programs.bash.bashrcExtra`

---

## Phase 3: Migrate Interactive Shell Config (`bashrcExtra` -> `initExtra`)

Goal: Move bashrc content to zsh's `~/.zshrc` equivalent (`programs.zsh.initExtra`).

- [ ] **External bashrc source**: Decide whether to convert `~/Gist/Config/bashrc` to zsh syntax or inline its contents into nix. Recommended: inline into nix.
- [ ] **Nix profile source**: Remove the `~/.nix-profile/etc/profile.d/nix.sh` source block (usually redundant in home-manager). If needed, place in `programs.zsh.envExtra`.
- [ ] **Bash completion**: Remove the `bash-completion` source block entirely.
- [ ] **Zsh completion**: Enable `programs.zsh.enableCompletion = true;`
- [ ] **Prompt (PS1)**: Rewrite bash PS1 for zsh. Options:
  - [ ] Option A: Use `programs.starship.enable = true;` (recommended)
  - [ ] Option B: Write zsh-native `PROMPT` in `programs.zsh.initExtra`
  - [ ] Option C: Enable `programs.zsh.oh-my-zsh` with a theme
- [ ] **Window title**: Convert embedded `\[\e]2;\w\a\]` in PS1 to a zsh `precmd` hook:
  ```zsh
  precmd() { print -Pn "\e]2;%~\a" }
  ```
- [ ] **WSL2 directory sync**: Convert bash `PROMPT_COMMAND` to zsh `precmd`:
  ```zsh
  precmd() { printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")" }
  ```

---

## Phase 4: Migrate Module-Specific `bashrcExtra` Snippets

For each module that injects into bash, add a zsh equivalent or use a home-manager native option.

- [ ] `usr/cli/tmux.nix`: Copy/adapt tmux bashrc snippet to `programs.zsh.initExtra`
- [ ] `usr/cli/ssh.nix`: Copy/adapt ssh bashrc snippet to `programs.zsh.initExtra`
- [ ] `usr/cli/clash.nix`: Copy/adapt clash bashrc snippet to `programs.zsh.initExtra`
- [ ] `usr/cli/fzf.nix`: Replace `bashrcExtra` with `programs.fzf.enableZshIntegration = true;`
- [ ] `usr/cli/tailscale.nix`: Copy/adapt tailscale bashrc snippet to `programs.zsh.initExtra`
- [ ] `usr/cli/vim/nvim-lspconfig/scala.nix`: Copy/adapt scala bashrc snippet to `programs.zsh.initExtra`

---

## Phase 5: Consolidate Zsh Configuration

- [ ] Move or merge `programs.zsh.initContent` (`usr/default.nix:21`) into `programs.zsh.initExtra` if desired
- [ ] Add quality-of-life options to `usr/cli/zsh/default.nix`:
  ```nix
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;  # keep existing
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 100000;
  };
  ```

---

## Phase 6: Decide on Login Shell Strategy

### Option A: Keep Bash Forwarding (Recommended)

- [ ] Keep `usr/cli/zsh/bash-zsh-forward.nix` imported
- [ ] Keep `programs.bash.enable = true`
- [ ] Strip `programs.bash.bashrcExtra` down to **only** the forwarding logic (remove all migrated config)
- [ ] No `chsh` required; works on systems without root

### Option B: Make Zsh the True Login Shell

- [ ] Check if zsh is in `/etc/shells`: `grep zsh /etc/shells`
- [ ] If NOT listed and you do NOT have root: **stop here, use Option A**
- [ ] If listed: run `chsh -s $(which zsh)`
- [ ] Remove/disable `usr/cli/zsh/bash-zsh-forward.nix`
- [ ] Move login-critical code to `programs.zsh.profileExtra` or `programs.zsh.loginExtra`

---

## Phase 7: Clean Up Bash Config

- [ ] Remove all non-forwarding content from `programs.bash.bashrcExtra`
- [ ] Decide whether to keep `programs.bash.enable = true` (needed for Option A, optional for Option B)
- [ ] If keeping bash enabled, consider setting `programs.bash.shellAliases = config.home.shellAliases` to share aliases as a fallback

---

## Phase 8: Rebuild and Validate

- [ ] Run `home-manager switch`
- [ ] Open a **brand new** terminal window (do not nest shells)
- [ ] Verify active shell: `echo $0` should show `-zsh` or `zsh`
- [ ] Verify aliases:
  - [ ] `type cat` -> `bat -pp`
  - [ ] `type ls` -> `eza`
  - [ ] `type mr` -> `mr -d ~`
- [ ] Verify completion: `nix <TAB>` should show completions
- [ ] Verify prompt: colors, user, host, working directory, newline, `$`
- [ ] Verify window title changes when navigating directories
- [ ] (WSL2 only) Verify new Windows Terminal tabs open in same directory
- [ ] Verify `direnv` integration works in a project directory
- [ ] Verify `fzf` integration works (Ctrl-T, Ctrl-R, Alt-C)

### Emergency Rollback

If anything breaks and you cannot get a working shell:

```bash
# From a broken zsh prompt, or via SSH with a broken profile:
bash --norc --noprofile

# Or force bash explicitly:
SHELL=/bin/bash bash -l

# Then edit your nix files and rerun:
home-manager switch
```

---

## Appendix: File Mapping Reference

| Bash Option | Zsh Option | File |
|-------------|------------|------|
| `programs.bash.bashrcExtra` | `programs.zsh.initExtra` | `~/.zshrc` |
| `programs.bash.profileExtra` | `programs.zsh.profileExtra` | `~/.zprofile` |
| `programs.bash.sessionVariables` | N/A (use `home.sessionVariables`) | N/A |
| `programs.bash.shellAliases` | `programs.zsh.shellAliases` or `home.shellAliases` | `~/.zshrc` |
| N/A | `programs.zsh.envExtra` | `~/.zshenv` |
| N/A | `programs.zsh.loginExtra` | `~/.zlogin` |
| N/A | `programs.zsh.completionInit` | `~/.zshrc` |

---

## Appendix: Prompt Translation Quick Reference

| Bash | Zsh |
|------|-----|
| `\u` | `%n` |
| `\h` | `%m` |
| `\w` | `%~` |
| `\$` | `%#` (or `$`) |
| `\[` / `\]` | `%{...%}` or `%F{color}` |
| `$?` | `%?` |
| `\n` | `$'\\n'` |
| `PROMPT_COMMAND` | `precmd()` hook |

---
