> **Note to AI agents / humans:** When an item in this checklist is completed, delete it from the file to keep the checklist actionable. Do not leave completed items checked or unchecked.

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
