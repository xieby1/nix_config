#MC gnome planner: task dependencies management
{ planner, runCommand, xorg }:
runCommand "planner" {} ''
  mkdir -p $out
  ${xorg.lndir}/bin/lndir -silent ${planner} $out
  # files in share/mime/ conflicts with ~/.local/share/mime/
  rm $(find -L $out/share/mime/ -maxdepth 1 -type f)
''
