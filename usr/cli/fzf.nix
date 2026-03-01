{ pkgs, ... }: let
  go-there = pkgs.writeScriptBin "go-there" /*bash*/ ''
    dir=$(dirname "$1")
    cd "$dir" || exit
    bash -i
  '';
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
    cd $(dirname "$FILE")
    FILE=$(basename "$FILE")

    # move o and go-there to top
    { echo o; echo go-there; allCmds | grep -vw o | grep -vw go-there; } | fzf \
      --bind     "enter:execute(      bash -ic '{} \"$FILE\"'               )+accept" \
      --bind "alt-enter:execute(nohup bash -ic '{} \"$FILE\"' &> /dev/null &)+accept"
  '';
in {
  home.packages = [
    go-there
    fzf-doc
  ];
  programs.bash.bashrcExtra = ''
    # FZF top-down display
    export FZF_DEFAULT_OPTS="--reverse"
  '';
  programs.fzf = {
    enable = true;
    # * hstr: not handle `~` correctly, always expand
    # * atuin: often not record my command, do know why
    #   * besides, the network sync is redundant for me
    # * mcfly: the fuzzy ranking algorithm is not as good/intuitive as fzf
    enableBashIntegration = true;
  };
}
