{ ... }: {
  _module.args = {
    # TODO: move to usr/default.nix
    isNixOnDroid = (builtins.getEnv "USER") == "nix-on-droid";
  };
  imports = [
    ./ai
  ];
}
