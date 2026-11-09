{ config, ... }:
{
  imports = [
    ((import ../npins/hierarchy.nix).my.xingyao + /nix/home-manager/xingyao.nix)
  ];

  services.xingyao = {
    enable = true;
    instances.main = {
      dataDir = "${config.home.homeDirectory}/Repos/BTeam/XingYaoData";
      port = 3004;
      basePath = "/BTeam/XingYao/";
      initializeWithSamples = true;
    };
  };
}
