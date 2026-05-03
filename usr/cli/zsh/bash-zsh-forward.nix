{ config, lib, ... }: {
  # TLATER's trick: https://discourse.nixos.org/t/using-home-manager-to-control-default-user-shell/8489/4
  #
  # Home-manager can only manage dotfiles (e.g. ~/.zshrc), but it cannot change
  # the login shell because that requires writing to /etc/passwd — a privileged
  # operation guarded by chsh.
  #
  # chsh enforces that any new shell must be listed in /etc/shells. A nix-installed
  # zsh is typically not in that file, and only root can add it. Therefore,
  # `chsh -s $(which zsh)` fails for unprivileged users.
  #
  # Workaround: instead of changing the system login shell, we make bash *hand
  # over* control to zsh immediately on startup. The `exec` system call replaces
  # the bash process with zsh, so from the user's perspective zsh is the
  # interactive shell, even though /etc/passwd still nominally lists bash.
  #
  # We inject the exec into two bash startup files to cover all entry points:
  #   - profileExtra  → ~/.bash_profile  (login shells: SSH, TTY login)
  #   - bashrcExtra   → ~/.bashrc        (interactive non-login shells: new terminals)
  programs.bash.bashrcExtra = lib.mkBefore ''
    # _ZSH_FORWARDED is a guard variable.
    # We must not exec if we are already inside a zsh-forwarded
    # session. Otherwise, explicitly running `bash` from zsh would immediately
    # bounce back into zsh, making it impossible to get a bash shell on demand.
    # The marker is set here and inherited through exec into zsh, so child bash
    # processes see it and skip the forwarding logic.
    #
    # The $- == *i* check ensures we only forward interactive shells.
    # Without this, non-interactive login shells (e.g. from niri-session's
    # wrapper or other display manager session startup) would get hijacked.
    if [[ -z "$_ZSH_FORWARDED" && $- == *i* ]]; then
        export _ZSH_FORWARDED=1
        exec ${config.programs.zsh.package}/bin/zsh
    fi
  '';
}
