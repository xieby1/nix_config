{ ... }: {
  # TODO: move _module.args to ../default.nix aka <root>/usr/default.nix
  _module.args = import ../../global-args;

  imports = [
    ../../modules
    ./yq-merge
    ./syncthing-gist-ignore.nix
  ];
}
