{ config, lib, ...}:

{
  imports = [../../modules/cachix.nix];
  config = lib.mkIf (
    (builtins.pathExists config.cachix_dhall) &&
    (config.cachix_packages != [])
  ) {
    home.activation = lib.hm.dag.entryAfter ["writeBoundary"] config._cachix_push;
  };
}
