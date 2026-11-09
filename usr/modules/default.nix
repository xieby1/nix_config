{ pkgs, lib, config, ... }: {
  _module.args = {
    # Though (import ./.) is callable and can serve as `npinsFun`,
    # I want `npinsFun` to be clean, without other attributes mixed in.
    npinsFun = (import ../../npins).__functor null;
  }; # Compared with my localArgs, this is globalArgs.

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
