{ pkgs, config, lib, ...}: {
  imports = [ ../cachix-push.nix ];

  # ~/Gist is synced on every device, but $HOME differs per device, so never hardcode a home path.
  cachix_dhall = lib.mkDefault "${config.home.homeDirectory}/Gist/Config/cachix.dhall";

  home.activation.cachix_push = lib.mkIf (
    (builtins.pathExists config.cachix_dhall) &&
    (config.cachix_packages != [])
  ) (lib.hm.dag.entryAfter ["writeBoundary"] config._cachix_push);
}
