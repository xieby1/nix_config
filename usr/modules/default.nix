{ pkgs, lib, config, ... }: {
  _module.args = {
    # Though (import ./.) is callable and can serve as `npinsFun`,
    # I want `npinsFun` to be clean, without other attributes mixed in.
    npinsFun = (import ../../npins).__functor null;
  }; # Compared with my localArgs, this is globalArgs.

  imports = [
    ../../modules
    ./yq-merge
    ./syncthing-gist-ignore.nix
  ];
}
