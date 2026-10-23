{ pkgs, lib, config, ... }: {
  imports = [
    ../../modules
    ./cachix.nix
    ./yq-merge
    ./syncthing-gist-ignore.nix
  ];
  # Why move pkgs.yq-go here instead of inside of yq-merge?
  # Becasue: the yq-merge module may be use outside of my config (e.g. test.nix),
  #          so the cachix_packages may be undefined inside the yq-merge module!
  cachix_packages = [ pkgs.yq-go ];
  # ~/Gist is synced on every device, but $HOME differs per device, so never hardcode a home path.
  cachix_dhall = lib.mkDefault "${config.home.homeDirectory}/Gist/Config/cachix.dhall";
}
