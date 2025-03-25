{ pkgs, ... }: {
  home.packages = with pkgs; [
    universal-ctags
  ];
  home.file.exclude_ctags = {
    text = ''
      # exclude ccls generated directories
      --exclude=.ccls*
    '';
    target = ".config/ctags/exclude.ctags";
  };
}
