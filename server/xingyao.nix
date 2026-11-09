{ config, ... }:
{
  imports = [
    ((import ../npins/hierarchy.nix).my.xingyao + /nix/home-manager/xingyao.nix)
  ];

  services.xingyao = {
    enable = true;
    instances.main = {
      dataDir = "${config.xdg.dataHome}/xingyao-main";
      port = 3004;
      basePath = "/BTeam/XingYao/";
      initializeWithSamples = true;
    };
  };
}
