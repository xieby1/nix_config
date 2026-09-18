{ config, lib, ...}: {
  config = lib.mkIf (
    (builtins.pathExists config.cachix_dhall) &&
    (config.cachix_packages != [])
  ) {
    system.activationScripts = {
      cachix_push = config._cachix_push;
    };
  };
}
