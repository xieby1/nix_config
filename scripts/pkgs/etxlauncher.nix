let
  pkgs = import <nixpkgs> {};
  name = "etxlauncher";
  etxlauncher = pkgs.stdenv.mkDerivation {
    inherit name;
    src = ~/Downloads/ETXLauncher-12.0.4.7508-SP4-linux-x64.tar.gz;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
  desktop = pkgs.makeDesktopItem {
    inherit name;
    desktopName = "ETX Client Launcher 12";
    exec = "${name} %u -gui";
    comment = "ETX Client Launcher";
    icon = "${etxlauncher}/icons/etxlauncher.128.png";
    categories = ["Application" "Network"];
    mimeTypes = ["x-scheme-handler/etx12"];
    noDisplay = true;
  };
in pkgs.buildFHSEnvBubblewrap {
  inherit name;
  runScript = pkgs.writeShellScript name ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
      pkgs.gtk2
      pkgs.gdk-pixbuf
      pkgs.glib
      pkgs.libkrb5
      pkgs.libx11
      pkgs.libxext
      pkgs.gtk3
    ]}
    ${etxlauncher}/bin/etxlauncher $@
  '';
  # TODO: mime
  # xdg-mime default etxlauncher.desktop x-scheme-handler/etx12
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${desktop}/share/applications/* $out/share/applications
  '';
  extraBwrapArgs = ["--bind $HOME/.local/share/${name} $HOME"];
  chdirToPwd = false;
}
