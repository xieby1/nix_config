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
  home.file.scala_ctags = {
    target = ".config/ctags/scala.ctags";
    text = ''
      --langdef=Scala
      --langmap=Scala:.scala
      --regex-Scala=/^[ \t]*class[ \t]*([a-zA-Z0-9_]+)/\1/c,classes/
      --regex-Scala=/^[ \t]*object[ \t]*([a-zA-Z0-9_]+)/\1/o,objects/
      --regex-Scala=/^[ \t]*trait[ \t]*([a-zA-Z0-9_]+)/\1/t,traits/
      --regex-Scala=/^[ \t]*case[ \t]*class[ \t]*([a-zA-Z0-9_]+)/\1/r,cclasses/
      --regex-Scala=/^[ \t]*abstract[ \t]*class[ \t]*([a-zA-Z0-9_]+)/\1/a,aclasses/
      --regex-Scala=/^[ \t]*def[ \t]*([a-zA-Z0-9_=]+)[ \t]*.*[:=]/\1/m,methods/
      --regex-Scala=/[ \t]*val[ \t]*([a-zA-Z0-9_]+)[ \t]*[:=]/\1/V,values/
      --regex-Scala=/[ \t]*var[ \t]*([a-zA-Z0-9_]+)[ \t]*[:=]/\1/v,variables/
      --regex-Scala=/^[ \t]*type[ \t]*([a-zA-Z0-9_]+)[ \t]*[\[<>=]/\1/T,types/
      --regex-Scala=/^[ \t]*import[ \t]*([a-zA-Z0-9_{}., \t=>]+$)/\1/i,includes/
      --regex-Scala=/^[ \t]*package[ \t]*([a-zA-Z0-9_.]+$)/\1/p,packages/
    '';
  };
}
