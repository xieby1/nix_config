{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./gui/gnome.nix
  ];

  home.packages = with pkgs; [
    # browser
    google-chrome
    # network
    qv2ray
    kdeconnect
    # text
    #wpsoffice
    libreoffice
    marktext
    texmaker
    meld
    # script
    autokey
    # draw
    drawio
    aseprite-unfree
    # management
    zotero
    # entertainment
    mgba
    ## icon miss?
    #(retroarch.override {
    #  cores = with libretro; [
    #    libretro.beetle-gba
    #  ];
    #})
  ];

  home.file.v2ray_core = {
    source = pkgs.fetchzip {
      url = "https://github.com/v2fly/v2ray-core/releases/download/v4.44.0/v2ray-linux-64.zip";
      sha256 = "dn7AZzkvUNDYVyZv4MZGwE+lDesm3fc0ul+64K41bTE=";
      stripRoot = false;
    };
    target = ".config/qv2ray/vcore";
  };
  systemd.user.services.qv2ray = {
    Unit = {
      Description = "Auto start qv2ray";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.qv2ray.outPath}/bin/qv2ray";
    };
  };

  # cannot find `ps` command, I dk why.
  # ok I add PATH env where ps located, problem solved!
  systemd.user.services.autokey = {
    Unit = {
      Description = "Auto start autokey";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      # https://stackoverflow.com/questions/31902846/how-to-fix-error-xlib-error-displayconnectionerror-cant-connect-to-display-0
      Environment="\"PATH=/run/current-system/sw/bin\"";
      ExecStartPre = "${pkgs.xorg.xhost.outPath}/bin/xhost +";
      ExecStart = "${pkgs.autokey.outPath}/bin/autokey-gtk -l";
    };
  };
}
