#MC # xdot, the dot (graphviz) viewer
{ config, pkgs, stdenv, lib, ... }:
let
  #MC Add a xdot.desktop for my xdot.
  myxdot = pkgs.symlinkJoin {
    name = "myxdot";
    paths = [
      pkgs.xdot
      (pkgs.makeDesktopItem {
        name = "xdot";
        desktopName = "xdot";
        exec = "xdot %U";
        icon = builtins.toFile "cheatsheet.svg" ''
          <svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
            <rect width="100%" height="100%" rx="20%" ry="20%" fill="#F5F5F5"/>
            <text x="50%" y="50%" text-anchor="middle" dominant-baseline="middle" font-size="18" font-weight="bold" fill="#333333">
              xdot
            </text>
          </svg>
        '';
  })];};
in {
  home.packages = [
    myxdot
  ];
  #MC Open *.dot files with xdot.desktop by default.
  xdg.mime.types.dot = {
    name = "graphviz-dot";
    type = "text/graphviz-dot";
    pattern = "*.dot";
    defaultApp = "xdot.desktop";
  };
}
