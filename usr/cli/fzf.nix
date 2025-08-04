{ pkgs, ... }: let
  fzf-doc = pkgs.writeScriptBin "fzf-doc" ''
    allCmds() {
      # bash alias
      compgen -A alias

      # external commands
      # https://unix.stackexchange.com/questions/94775/list-all-commands-that-a-shell-knows
      case "$PATH" in
        (*[!:]:) PATH="$PATH:" ;;
      esac
      set -f
      IFS_OLD="$IFS"
      IFS=:
      for dir in $PATH; do
        set +f
        [ -z "$dir" ] && dir="."
        for file in "$dir"/*; do
          if [ -x "$file" ] && ! [ -d "$file" ]; then
            echo "''${file##*/}"
          fi
        done
      done
      IFS="$IFS_OLD"
    }

    cd ~/Documents
    FILE=$(fzf)
    [ -z "$FILE" ] && exit

    CMD=$(allCmds | fzf)
    [ -z "$CMD" ] && exit

    case "$CMD" in
    # run gui cmd background
    o)
      # use nohup to run bash command in background and exit
      ## https://superuser.com/questions/448445/run-bash-script-in-background-and-exit-terminal
      # nohup not recognize bash alias like `o`, it's necessary to call bash
      eval nohup bash -ic '"$CMD \"$FILE\" &"'
    ;;

    # run cli cmd foreground
    *)
      # FILE name may contain space, quote FILE name
      eval "$CMD" \"$FILE\"
    ;;
    esac
  '';
in {
  home.packages = [
    pkgs.fzf
    fzf-doc
  ];
  programs.bash.bashrcExtra = ''
    # FZF top-down display
    export FZF_DEFAULT_OPTS="--reverse"
  '';
}
