{ config, pkgs, stdenv, lib, ... }:
let
  my-firefox = pkgs.runCommand "firefox-pinch" {} ''
    mkdir -p $out
    ${pkgs.xorg.lndir}/bin/lndir -silent ${pkgs.firefox} $out
    path=share/applications/firefox.desktop
    rm $out/$path
    sed 's/Exec=/Exec=env MOZ_USE_XINPUT2=1 /' ${pkgs.firefox}/$path > $out/$path
  '';
in {
  home.packages = [
    my-firefox
  ];
}
