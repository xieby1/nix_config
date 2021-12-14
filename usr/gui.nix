{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./gui/gnome.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    qv2ray
    wpsoffice
    marktext
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

}
