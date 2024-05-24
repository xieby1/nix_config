#MC 用于自动push包到cachix的模块。
#MC 尽管cachix watch-store能自动push，但是我想更细粒度地管理需要push的包，所以有了这个模块。
{ config, pkgs, lib, ...}:

{
  options = {
    cachixPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = ''
        This list of packages.

        If the the cachix.dhall file exists and cachixPackages is not empty,
        then the packages in cachixPackages will be pushed to cachix.
      '';
    };
    cachix_dhall = lib.mkOption {
      type = lib.types.string;
      default = "/home/xieby1/Gist/Config/cachix.dhall";
      description = ''
        The path of cachix.dhall.
      '';
    };
    cachix_name = lib.mkOption {
      type = lib.types.string;
      default = "xieby1";
      description = ''
        The cachix name.
      '';
    };
  };

  config = lib.mkIf (
    (builtins.pathExists config.cachix_dhall) &&
    (config.cachixPackages != [])
  ) {
    # push the overrided mutter and gnome to my cachix
    system.activationScripts = {
      cachix_push = ''
        echo Pushing packages to cachix:
        ${lib.concatMapStrings (x: "echo 📦"+x+"\n") config.cachixPackages}
        ${pkgs.cachix}/bin/cachix -c ${config.cachix_dhall} push ${config.cachix_name} ${builtins.toString config.cachixPackages}
      '';
    };
  };
}
