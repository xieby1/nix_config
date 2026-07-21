{ config, ... }: {
  imports = [
    # Why not using pkgs.npinsed here? Because: pkgs cannot be used in imports, or it will cause infinite recursion.
    (let
      npinsed = import ../npins/hierarchy.nix;
      sixu-src = npinsed.my.sixu;
    in sixu-src + /nix/home-manager/sixu.nix)
  ];
  services.sixu = {
    enable = true;
    instances = {
      xby = {
        dataDir = "${config.home.homeDirectory}/Gist/Data/sixu/xby/";
        host = "127.0.0.1";
        port = 3000;
      };
      wxy = {
        dataDir = "${config.home.homeDirectory}/Gist/Data/sixu/wxy/";
        host = "127.0.0.1";
        port = 3001;
      };
    };
  };
}
