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
  programs.bash = {
    # For login bash (e.g. SSH, console login)
    profileExtra = lib.mkBefore "exec ${config.programs.zsh.package}/bin/zsh";
    # For interactive bash (e.g. new terminal emulator windows)
    bashrcExtra  = lib.mkBefore "exec ${config.programs.zsh.package}/bin/zsh";
  };
  programs.zsh = {
    enable = true;
  };
}
