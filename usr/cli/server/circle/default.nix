{ src }: # local-args
{ config, ... }:
{
  imports = [
    (src + /nix/home-manager/circle.nix)
  ];

  services.circle = {
    enable = true;
    instances = {
      xby = {
        dataDir = "${config.home.homeDirectory}/Gist/Data/circle/xby/";
        host = "127.0.0.1";
        port = 3002;
      };
      wxy = {
        dataDir = "${config.home.homeDirectory}/Gist/Data/circle/wxy/";
        host = "127.0.0.1";
        port = 3003;
      };
    };
  };
}
