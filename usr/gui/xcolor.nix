#MC # XColor
#MC
#MC Why use XColor instead of gcolor3 or eyedropper?
#MC Because they do not support zoom: e.g. https://github.com/FineFindus/eyedropper/issues/79
{ pkgs, ... }: {
  home.packages = [(
    let
      name = "xcolor-sleep";
      # [Error when launching xcolor from the Activities overview: Could not grab pointer #38](https://github.com/Soft/xcolor/issues/38)
      exec = pkgs.writeShellScript name ''
        for ((n=0; n<3; n++)); do
          ${pkgs.xcolor}/bin/xcolor -s && break
          sleep 0.2
        done
      '';
    in
    pkgs.runCommand name {} ''
      mkdir -p $out
      ${pkgs.xorg.lndir}/bin/lndir -silent ${pkgs.xcolor} $out
      rm $out/share/applications/XColor.desktop
      sed 's,^Exec.*,Exec=${exec},' ${pkgs.xcolor}/share/applications/XColor.desktop > $out/share/applications/XColor.desktop
    ''
  )];
}
