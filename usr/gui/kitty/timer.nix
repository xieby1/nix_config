{ lib, ... }: {
  ## after direnv's bash.initExtra
  programs.bash.initExtra = lib.mkOrder 2000 ''
    # https://stackoverflow.com/questions/1862510/how-can-the-last-commands-wall-time-be-put-in-the-bash-prompt
    function timer_start {
      _timer=''${_timer:-$SECONDS}
    }
    function timer_stop {
      last_timer=$(($SECONDS - $_timer))
      unset _timer

      _notification="[''${last_timer}s⏰] Job finished!"
      if [[ "$TERM" =~ tmux ]]; then
        # https://github.com/tmux/tmux/issues/846
        printf '\033Ptmux;\033\x1b]99;;%s\033\x1b\\\033\\' "$_notification"
      else
        printf '\x1b]99;;%s\x1b\\' "$_notification"
      fi
    }
  '';
  programs.kitty = {
    extraConfig = ''
      # Notify when a long running command is finished
      ## https://github.com/kovidgoyal/kitty/issues/1892
      map f1 send_text all \x1a timer_start; fg; timer_stop \r
    '';
  };
}
