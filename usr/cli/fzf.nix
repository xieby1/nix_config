{ pkgs, ... }: let
  fzf-doc = pkgs.writeScriptBin "fzf-doc" /*bash*/ ''
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

    allCmds | fzf \
      --bind     "enter:execute(      bash -ic '{} \"$FILE\"'               )+accept" \
      --bind "alt-enter:execute(nohup bash -ic '{} \"$FILE\"' &> /dev/null &)+accept"
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
