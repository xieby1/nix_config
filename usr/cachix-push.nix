{ pkgs, config, lib, ...}: {
  imports = [ ../cachix-push.nix ];

  # ~/Gist is synced on every device, but $HOME differs per device, so never hardcode a home path.
  cachix_dhall = lib.mkDefault "${config.home.homeDirectory}/Gist/Config/cachix.dhall";

  home.activation.cachix_push = lib.mkIf (
    (builtins.pathExists config.cachix_dhall) &&
    (config.cachix_packages != [])
  ) (lib.hm.dag.entryAfter ["writeBoundary"] config._cachix_push);

  # TODO: move it to where yq-merge is imported.
  # Why move pkgs.yq-go here instead of inside of yq-merge?
  # Becasue: the yq-merge module may be use outside of my config (e.g. test.nix),
  #          so the cachix_packages may be undefined inside the yq-merge module!
  cachix_packages = [ pkgs.yq-go ];
}
